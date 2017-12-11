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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private lazy var dropboxManager: DropboxManager = factory.resolve()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        application.isStatusBarHidden = false
        application.statusBarStyle = .lightContent
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouterVC().vcForCurrentState()
        window?.makeKeyAndVisible()
        
        AppConfigurator.applicationStarted()
        
        Fabric.with([Crashlytics.self])
            
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        startMenloworks(with: launchOptions)
        
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
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    private var firstResponder: UIResponder?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        firstResponder = application.firstResponder
        SDImageCache.shared().deleteOldFiles(completionBlock: nil)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        showPasscodeIfNeed()
    }
    
    private func showPasscodeIfNeed() {
        let topVC = UIApplication.topController()
        
        /// don't show at all or new PasscodeEnterViewController
        if passcodeStorage.isEmpty {
            return
        }
        
        if let vc = topVC as? PasscodeEnterViewController {
            vc.passcodeManager.authenticateWithBiometrics()
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
        
        topVC?.present(navVC, animated: true,completion: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        ApplicationSessionManager.shared().checkSession()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SDImageCache.shared().deleteOldFiles(completionBlock: nil)
    }
    
    // TODO: update for new app delegate
    override func remoteControlReceived(with event: UIEvent?) {
        if (event?.type == .remoteControl) {
            FactoryMain.mediaPlayer.handle(event: event)
        }
    }
    
}


//Notifications

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MPush.applicationDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        MPush.applicationDidFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        MPush.applicationDidReceiveRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        MPush.applicationDidReceive(notification)
    }
}


//Menloworks

extension AppDelegate {
    private func startMenloworks(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        var notificationTypes: NSInteger?
        if #available(iOS 8, *) {
            let types: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            notificationTypes = NSInteger(types.rawValue)
        } else {
            let types: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound, UIUserNotificationType.badge]
            notificationTypes = NSInteger(types.rawValue)
        }
        
        if notificationTypes != nil {
            MPush.register(forRemoteNotificationTypes: notificationTypes!)
            MPush.applicationDidFinishLaunching(options: launchOptions)
        }
    }
    
}







