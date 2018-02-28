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
let log = setupLog()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.orientationLock
    }
    
    private lazy var dropboxManager: DropboxManager = factory.resolve()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        log.debug("AppDelegate didFinishLaunchingWithOptions")
        
        application.isStatusBarHidden = false
        application.statusBarStyle = .lightContent
        
        AppConfigurator.applicationStarted(with: launchOptions)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouterVC().vcForCurrentState()
        window?.makeKeyAndVisible()
        
        
        
        Fabric.with([Crashlytics.self])
            
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        let documentDirectory: NSURL = {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls[urls.endIndex - 1] as NSURL
        }()
        let logPath: NSURL = documentDirectory.appendingPathComponent("app.log")! as NSURL
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: logPath, fileLevel: .debug)
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
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
            LocationManager.shared.startUpdateLocation()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        log.debug("AppDelegate applicationWillEnterForeground")
    }
    
    private func showPasscodeIfNeed() {
        /// don't show at all or new PasscodeEnterViewController
        if passcodeStorage.isEmpty {
            return
        }
        
        let topVC = UIApplication.topController()
        /// don't show on request biometrics
        if topVC is PasscodeEnterViewController {
            return
        }
        
        /// remove PasscodeEnterViewController if was on the screen
        if let tabBarVC = topVC as? TabBarViewController,
            let navVC = tabBarVC.activeNavigationController,
            navVC.topViewController is PasscodeEnterViewController
        {
            navVC.popViewController(animated: false)
        }
    
        /// present PasscodeEnterViewController
        let vc = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        vc.success = {
            topVC?.dismiss(animated: true, completion: {
                self.firstResponder?.becomeFirstResponder()
            })
        }
        
        let navVC = UINavigationController(rootViewController: vc)
        vc.navigationBarWithGradientStyleWithoutInsets()
        
        topVC?.present(navVC, animated: false,completion: nil)
    }
    
    private func checkPasscodeIfNeed() {
        if passcodeStorage.isEmpty {
            return
        }
        
        let topVC = UIApplication.topController()
        if let vc = topVC as? PasscodeEnterViewController, !vc.passcodeManager.finishBiometrics {
            vc.passcodeManager.authenticateWithBiometrics()
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        log.debug("AppDelegate applicationWillResignActive")
        
        showPasscodeIfNeed()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        log.debug("AppDelegate applicationDidBecomeActive")
        
        checkPasscodeIfNeed()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        log.debug("AppDelegate applicationWillTerminate")
        SyncServiceManager.shared.stopSync()
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

        MPush.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.debug("AppDelegate didFailToRegisterForRemoteNotificationsWithError")

        MPush.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        log.debug("AppDelegate didReceiveRemoteNotification")

        MPush.applicationDidReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.debug("AppDelegate didReceive")

        MPush.applicationDidReceive(notification)
    }
}

private func setupLog() -> XCGLogger {
    // Create a logger object with no destinations
    let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
    
    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")
    
    // Optionally set some configuration options
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    systemDestination.showDate = true
    
    // Add the destination to the logger
    log.add(destination: systemDestination)
    
    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()
    
    return log
}
