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
    lazy var dropboxManager: DropboxManager = factory.resolve()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        application.isStatusBarHidden = false
        application.statusBarStyle = .lightContent
        
//        Fabric.with([Crashlytics.self])
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RouterVC().vcForCurrentState()
        window?.makeKeyAndVisible()
        
        AppConfigurator.applicationStarted()
        
        Fabric.with([Crashlytics.self])
            
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        PasscodeManager.shared.show()
//        PasscodeStorageDefaults().save(passcode: "2222")
        
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
    func applicationDidEnterBackground(_ application: UIApplication) {
        SDImageCache.shared().deleteOldFiles(completionBlock: nil)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        let topVC = UIApplication.topController()
        if topVC is PasscodeEnterViewController {
//            RouterVC().navigationController?.popViewController(animated: false)
            return
        }
        if PasscodeStorageDefaults().isEmpty {
            return
        }
        let vc = PasscodeEnterViewController.with(flow: .validate)
        vc.success = {
            topVC?.dismiss(animated: true, completion: nil)
        }
        topVC?.present(vc, animated: true,completion: nil)
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        ApplicationSessionManager.shared().checkSession()
    }
    func applicationWillTerminate(_ application: UIApplication) {
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

extension UIApplication {
    
    class func topController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topController(controller: presented)
        }
        return controller
    }
}
