//
//  AppDelegate.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FBSDKCoreKit
import SDWebImage
import XCGLogger

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
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        log.debug("AppDelegate didFinishLaunchingWithOptions")
        
        AppConfigurator.applicationStarted(with: launchOptions)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouterVC().vcForCurrentState()
        window?.makeKeyAndVisible()
        

        Fabric.with([Crashlytics.self])
            
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FBSDKAppLinkUtility.fetchDeferredAppLink { url, error in
            if let url = url {
                if UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            } else {
                log.debug("Received error while fetching deferred app link \(String(describing: error))")
            }
        }
        
        MenloworksAppEvents.onAppLaunch()
        MenloworksTagsService.shared.passcodeStatus(!passcodeStorage.isEmpty)
        ContactSyncSDK.doPeriodicSync()
        passcodeStorage.systemCallOnScreen = false
        
        return true
    }
    
    /// iOS 9+
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options) {
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
        log.debug("AppDelegate applicationDidEnterBackground")

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
        log.debug("AppDelegate applicationWillEnterForeground")
        
        ContactSyncSDK.doPeriodicSync()
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
            vc.becomeResponder() /// need for iPad
            if !vc.passcodeManager.finishBiometrics {
                vc.passcodeManager.authenticateWithBiometrics()
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        log.debug("AppDelegate applicationWillResignActive")
        
        showPasscodeIfNeed()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        log.debug("AppDelegate applicationDidBecomeActive")
        
        checkPasscodeIfNeed()
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        log.debug("AppDelegate applicationWillTerminate")
        
        if !tokenStorage.isRememberMe {
            SyncServiceManager.shared.stopSync()
            AutoSyncDataStorage().clear()
        }
        
        WidgetService.shared.notifyWidgetAbout(status: .stoped)
        
        UserDefaults.standard.synchronize()
        player.stop()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        log.debug("AppDelegate applicationDidReceiveMemoryWarning")

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
        log.debug("AppDelegate didRegisterForRemoteNotificationsWithDeviceToken")
        MenloworksTagsService.shared.onNotificationPermissionChanged(true)
        
        MPush.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        FBSDKAppEvents.setPushNotificationsDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.debug("AppDelegate didFailToRegisterForRemoteNotificationsWithError")
        MenloworksTagsService.shared.onNotificationPermissionChanged(false)

        MPush.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        self.application(application, didReceiveRemoteNotification: userInfo) { result in
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log.debug("AppDelegate didReceiveRemoteNotification")
        MPush.applicationDidReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
        
        FBSDKAppEvents.logPushNotificationOpen(userInfo)
        
        if PushNotificationService.shared.assignNotificationActionBy(launchOptions: userInfo) {
            PushNotificationService.shared.openActionScreen()
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.debug("AppDelegate didReceive")

        MPush.applicationDidReceive(notification)
    }
}
