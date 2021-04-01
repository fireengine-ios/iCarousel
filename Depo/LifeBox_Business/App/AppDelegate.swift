//
//  AppDelegate.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import FBSDKCoreKit
import SDWebImage
import XCGLogger
import Adjust
import Netmera
import UserNotifications
import KeychainSwift

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
    Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([string]))
}

func printLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    print(string)
    log.debug(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([string]))
}

func fatalLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) -> Never {
    debugLog(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    fatalError(string)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.orientationLock
    }
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    var window: UIWindow?
    var watchdog: Watchdog?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }

        startCoreDataSafeServices(with: application, options: launchOptions)
        
        APILogger.shared.startLogging()
        
        ///call debugLog only if the Crashlytics is already initialized
        debugLog("AppDelegate didFinishLaunchingWithOptions")
        
        let router = RouterVC()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = router.vcForCurrentState()
        self.window?.makeKeyAndVisible()
        
        self.window?.isHidden = false
        
        return true
    }
    
    private func startCoreDataSafeServices(with application: UIApplication, options: [UIApplicationLaunchOptionsKey: Any]?) {
        DispatchQueue.setupMainQueue()
    
        #if DEBUG
            watchdog = Watchdog(threshold: 0.05, strictMode: false)
        #endif
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Documents: \(documents)")
        
        setupPushNotifications(with: options) { [weak self] in
            self?.askPhotoGalleryPermission()
        }
        
        AppConfigurator.applicationStarted(with: options)
        
        passcodeStorage.systemCallOnScreen = false
        
        AppLinkUtility.fetchDeferredAppLink { url, error in
            if let url = url {
                UIApplication.shared.openSafely(url)
            } else {
                debugLog("Received error while fetching deferred app link \(String(describing: error))")
            }
        }
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: options)
    }
    
    private func setupPushNotifications(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?, completionHandler: @escaping () -> Void) {
        // required setup order
        // 1. subscribe to notification delegate
        // 2. Netmera SDK setup
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { _, _ in
            Netmera.requestPushNotificationAuthorization(forTypes: [.alert, .badge, .sound])
            AnalyticsPermissionNetmeraEvent.sendNotificationPermissionNetmeraEvents()
            completionHandler()
        }
        UNUserNotificationCenter.current().delegate = self
        AnalyticsService.startNetmera()
        debugLog("AppDelegate setupPushNotifications setuped")
    }
    
    private func askPhotoGalleryPermission() {
        PHPhotoLibrary.requestAuthorizationStatus { _ in }
    }
    
    /// iOS 9+
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        Adjust.appWillOpen(url)
        
        if let urlHost = url.host {
            if PushNotificationService.shared.assignDeepLink(innerLink: urlHost, options: options) {
                PushNotificationService.shared.openActionScreen()
            }
        }
        
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
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
    }
    
    func showPasscodeIfNeedInBackground() {
        let state = ApplicationStateHelper.shared.safeApplicationState
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
        let passcodeController = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        passcodeController.success = {
            topVC?.dismiss(animated: true, completion: {
                self.firstResponder?.becomeFirstResponder()
            })
        }
        
        let navVC = NavigationController(rootViewController: passcodeController)
        navVC.modalPresentationStyle = .overFullScreen
        
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugLog("AppDelegate didRegisterForRemoteNotificationsWithDeviceToken")
        AnalyticsPermissionNetmeraEvent.sendNotificationPermissionNetmeraEvents()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugLog("AppDelegate didFailToRegisterForRemoteNotificationsWithError")
        AnalyticsPermissionNetmeraEvent.sendNotificationPermissionNetmeraEvents()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        self.application(application, didReceiveRemoteNotification: userInfo) { result in
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugLog("AppDelegate didReceiveRemoteNotification")
        
        AppEvents.logPushNotificationOpen(userInfo)
    }
    
    //MARK: Adjust
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            if PushNotificationService.shared.assignUniversalLink(url: url) {
                PushNotificationService.shared.openActionScreen()
                return true
            }
            
            Adjust.appWillOpen(url)
                
            if let oldURL = Adjust.convertUniversalLink(url, scheme: SharedConstants.applicationQueriesSchemeShort) {
                debugLog("Adjust old path :\(oldURL.path)")
                if let host = oldURL.host {
                    debugLog("Adjust old host :\(host)")
                    if PushNotificationService.shared.assignDeepLink(innerLink: host, options: userActivity.userInfo) {
                        debugLog("Should open Action Screen")
                        PushNotificationService.shared.openActionScreen()
                    }
                }
            }
        }
        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugLog("userNotificationCenter didReceive response")

        if let options = Netmera.recentPushObject()?.customDictionary ?? response.notification.request.content.userInfo[PushNotificationParameter.netmeraParameters.rawValue] as? [AnyHashable: Any] {
            debugLog("userNotificationCenter try to handle Netmera push object")
            if PushNotificationService.shared.assignNotificationActionBy(launchOptions: options) {
                PushNotificationService.shared.openActionScreen()
                completionHandler()
                return
            }
        } else {
            debugLog("userNotificationCenter Netmera push object is empty")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
