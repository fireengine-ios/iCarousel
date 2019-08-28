//
//  AppDelegate.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Crashlytics
import FBSDKCoreKit
import SDWebImage
import XCGLogger
import Adjust
import XPush

// the global reference to logging mechanism to be available in all files
let log: XCGLogger = {
    let log = XCGLogger(identifier: XCGLogger.lifeboxAdvancedLoggerIdentifier, includeDefaultDestinations: false)
    
    let logPath = Device.documentsFolderUrl(withComponent: XCGLogger.lifeboxLogFileName)
    
    let autoRotatingFileDestination = AutoRotatingFileDestination(owner: log,
                                                                  writeToFile: logPath,
                                                                  identifier: XCGLogger.lifeboxFileDestinationIdentifier,
                                                                  shouldAppend: true,
                                                                  appendMarker: XCGLogger.lifeboxAppendMarker,
                                                                  attributes: [.protectionKey : FileProtectionType.completeUntilFirstUserAuthentication],
                                                                  maxFileSize: NumericConstants.logMaxSize,
                                                                  maxTimeInterval: NumericConstants.logDuration,
                                                                  archiveSuffixDateFormatter: nil)
    autoRotatingFileDestination.outputLevel = .debug
    autoRotatingFileDestination.showLogIdentifier = true
    autoRotatingFileDestination.showFunctionName = true
    autoRotatingFileDestination.showThreadName = true
    autoRotatingFileDestination.showLevel = true
    autoRotatingFileDestination.showFileName = true
    autoRotatingFileDestination.showLineNumber = true
    autoRotatingFileDestination.showDate = true
    autoRotatingFileDestination.logQueue = XCGLogger.logQueue
    
    log.add(destination: autoRotatingFileDestination)
    
    log.logAppDetails()
    
    return log
}()

func debugLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    log.debug(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    CLSLogv("%@", getVaList([string]))
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.orientationLock
    }
    
    
    private lazy var dropboxManager: DropboxManager = factory.resolve()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    var window: UIWindow?
    var watchdog: Watchdog?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        AppConfigurator.applicationStarted(with: launchOptions)
        #if DEBUG
            watchdog = Watchdog(threshold: 0.05, strictMode: false)
        #endif
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Documents: \(documents)")
        
        ///call debugLog only if the Crashlytics is already initialized
        debugLog("AppDelegate didFinishLaunchingWithOptions")
        
        let router = RouterVC()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = router.vcForCurrentState()
        window?.makeKeyAndVisible()
            
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        AppLinkUtility.fetchDeferredAppLink { url, error in
            if let url = url {
                UIApplication.shared.openSafely(url)
            } else {
                debugLog("Received error while fetching deferred app link \(String(describing: error))")
            }
        }
        
        ContactSyncSDK.doPeriodicSync()
        passcodeStorage.systemCallOnScreen = false
        
        MenloworksAppEvents.onAppLaunch()
        
        return true
    }
    
    /// iOS 9+
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        Adjust.appWillOpen(url)
        
        if let urlHost = url.host {
            if PushNotificationService.shared.assignDeepLink(innerLink: urlHost){
                PushNotificationService.shared.openActionScreen()
                storageVars.deepLink = urlHost
            }
        }
        
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        } else if dropboxManager.handleRedirect(url: url) {
            return true
        }
        return false
    }
    
    /// iOS targets < 9
    /// TODO: for Facebook ???
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if dropboxManager.handleRedirect(url: url) {
            return true
        }
        return false
    }
    
    private var firstResponder: UIResponder?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugLog("AppDelegate applicationDidEnterBackground")
        
        BackgroundTaskService.shared.beginBackgroundTask()

        firstResponder = application.firstResponder
        SDImageCache.shared().deleteOldFiles(completionBlock: nil)
        
        if tokenStorage.refreshToken != nil {
            LocationManager.shared.startUpdateLocationInBackground()
        }
        
        if !passcodeStorage.isEmpty {
            let topVC = UIApplication.topController()
            
            /// remove PasscodeEnterViewController if was on the screen
            if let tabBarVC = topVC as? TabBarViewController,
                let navVC = tabBarVC.activeNavigationController,
                navVC.topViewController is PasscodeEnterViewController {
                navVC.popViewController(animated: false)
                showPasscodeIfNeed()
            } else if passcodeStorage.systemCallOnScreen {
                passcodeStorage.systemCallOnScreen = false
                showPasscodeIfNeed()
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        debugLog("AppDelegate applicationWillEnterForeground")
        if BackgroundTaskService.shared.appWasSuspended {
            CacheManager.shared.actualizeCache(completion: nil)
        }
        ContactSyncSDK.doPeriodicSync()
        MenloworksAppEvents.sendProfileName()
    }
    
    func showPasscodeIfNeedInBackground() {
        let state = UIApplication.shared.applicationState
        if state == .background || state == .inactive {
            showPasscodeIfNeed()
        }
    }
    
    private func showPasscodeIfNeed() {
        let topVC = UIApplication.topController()
        
        if let topVC = topVC as? PasscodeEnterViewController, topVC.passcodeManager.userCancelledBiometrics {
            topVC.passcodeManager.finishBiometrics = false
        }
        
        /// don't show at all or new PasscodeEnterViewController
        if passcodeStorage.isEmpty || passcodeStorage.systemCallOnScreen || topVC is PasscodeEnterViewController {
            return
        }
        
        /// remove PasscodeEnterViewController if was on the screen and biometrics is disable
        if let tabBarVC = topVC as? TabBarViewController,
            let navVC = tabBarVC.activeNavigationController,
            navVC.topViewController is PasscodeEnterViewController {
            if biometricsManager.isEnabled {
                return
            } else {
                navVC.popViewController(animated: false)
            }
        }
        
        if topVC is UIAlertController {
            topVC?.dismiss(animated: false, completion: {
                self.showPasscode()
            })
        } else {
            showPasscode()
        } 
    }
    
    private func showPasscode() {
        let topVC = UIApplication.topController()
        
        /// present PasscodeEnterViewController
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        vc.success = {
            topVC?.dismiss(animated: true, completion: {
                self.firstResponder?.becomeFirstResponder()
            })
        }
        
        let navVC = NavigationController(rootViewController: vc)
        vc.navigationBarWithGradientStyleWithoutInsets()
        
        topVC?.present(navVC, animated: false, completion: nil)
    }
    
    private func checkPasscodeIfNeed() {
        if passcodeStorage.isEmpty {
            return
        }
        
        let topVC = UIApplication.topController()
        if let vc = topVC as? PasscodeEnterViewController {
            if !vc.passcodeManager.finishBiometrics {
                vc.passcodeManager.authenticateWithBiometrics()
            } else if !vc.passcodeManager.successFinishBiometrics {
                vc.becomeResponder()
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        debugLog("AppDelegate applicationWillResignActive")
        
        showPasscodeIfNeed()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        debugLog("AppDelegate applicationDidBecomeActive")
        checkPasscodeIfNeed()
        AppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        debugLog("AppDelegate applicationWillTerminate")
        
        if !tokenStorage.isRememberMe {
            SyncServiceManager.shared.stopSync()
            AutoSyncDataStorage().clear()
        }
        
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        
        UserDefaults.standard.synchronize()
        
        player.stop()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        debugLog("AppDelegate applicationDidReceiveMemoryWarning")

        SDImageCache.shared().deleteOldFiles(completionBlock: nil)
    }
    
    // TODO: update for new app delegate
    override func remoteControlReceived(with event: UIEvent?) {
        if (event?.type == .remoteControl) {
            player.handle(event: event)
        }
    }
    
}


//Notifications

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        debugLog("AppDelegate didRegister notificationSettings")
        if #available(iOS 10, *) {
            ///deprecated
            ///call appendLocalMediaItems in the AppConfigurator
            return
        }
        /// start photos logic after notification permission///MOVED TO CACHE MANAGER, when all remotes are added.
//        MediaItemOperationsService.shared.appendLocalMediaItems(completion: nil)
        LocalMediaStorage.default.askPermissionForPhotoFramework(redirectToSettings: false){ available, status in
            
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugLog("AppDelegate didRegisterForRemoteNotificationsWithDeviceToken")
        MenloworksTagsService.shared.onNotificationPermissionChanged(true)
        
        XPush.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugLog("AppDelegate didFailToRegisterForRemoteNotificationsWithError")
        MenloworksTagsService.shared.onNotificationPermissionChanged(false)

        XPush.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        self.application(application, didReceiveRemoteNotification: userInfo) { result in
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugLog("AppDelegate didReceiveRemoteNotification")
        XPush.applicationDidReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
        
        AppEvents.logPushNotificationOpen(userInfo)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        debugLog("AppDelegate didReceive")

        XPush.applicationDidReceive(notification)
    }
    
    //MARK: Adjust
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                
                Adjust.appWillOpen(url)
                
                if let oldURL = Adjust.convertUniversalLink(url, scheme:"akillidepo") {
                    if let host = oldURL.host {
                        debugLog("Adjust old host :\(oldURL.host)")
                        if PushNotificationService.shared.assignDeepLink(innerLink: host){
                            debugLog("Should open Action Screen")
                            PushNotificationService.shared.openActionScreen()
                            storageVars.deepLink = host
                        }
                    }
                    debugLog("Adjust old path :\(oldURL.path)")
                }
            }
        }
        return true
    }
}
