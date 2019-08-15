//
//  AppConfigurator.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import Adjust
import KeychainSwift
import Fabric
import Crashlytics

final class AppConfigurator {
    
    static let dropboxManager: DropboxManager = factory.resolve()
    static let analyticsManager: AnalyticsService = factory.resolve()
    static let storageVars: StorageVars = factory.resolve()
    static let tokenStorage: TokenStorage = factory.resolve()
    
    static func applicationStarted(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        DispatchQueue.setupMainQueue()
        
        Fabric.with([Crashlytics.self])
        
        /// force arabic language left to right
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        AppResponsivenessService.shared.startMainAppUpdate()
        firstStart()
        clearTokensIfNeed()
        logoutIfNeed()
        prepareSessionManager()
        SettingsBundleHelper.setVersionAndBuildNumber()
        SettingsBundleHelper.shared().startObservingForLifeTech()
        configureSDWebImage()
        setupIAPObserver()
        startMenloworks(with: launchOptions)
        setupCropy()
        dropboxManager.start()
        analyticsManager.start()
        
        AppWormholeListener.shared.startListen()
        _ = PushNotificationService.shared.assignNotificationActionBy(launchOptions: launchOptions)
        LocalMediaStorage.default.clearTemporaryFolder()
        
        startUpdateLocation(with: launchOptions)
        
        AuthoritySingleton.shared.checkNewVersionApp()
        
        PremiumService.shared.addObserverForSyncStatusDidChange()
    }
    
    private static func setupIAPObserver() {
        let _ = IAPManager.shared ///setup observer on the didLaunch, as apple suggest
    }
    
    private static func firstStart() {
        if storageVars.isAppFirstLaunch {
            debugLog("isAppFirstLaunch")
            storageVars.isAppFirstLaunch = false
            KeychainSwift().clear()
            /// call migrate after Keychain clear
            AppMigrator.migrateAll()
        }
    }
    
    static func logout() {
        /// there is no retain circle bcz of singleton
        AuthenticationService().logout {
            DispatchQueue.main.async {
                let router = RouterVC()
                router.setNavigationController(controller: router.onboardingScreen)
            }
        }
    }
    
    private static func clearTokensIfNeed() {
        if tokenStorage.isClearTokens {
            debugLog("clearTokensIfNeed")
            tokenStorage.isClearTokens = false
            tokenStorage.clearTokens()
        }
    }
    
    private static func logoutIfNeed() {
        if !tokenStorage.isRememberMe {
            debugLog("logoutIfNeed isRememberMe false")
            AuthenticationService().logout(async: false, success: nil)
        }
    }
    
   private static func prepareSessionManager() {
        var auth: AuthorizationRepository = factory.resolve()
        auth.refreshFailedHandler = setRefreshFailedHandler
        
        let sessionManager = SessionManager.customDefault
        sessionManager.retrier = auth
        sessionManager.adapter = auth
    }
    
    static func setRefreshFailedHandler() {
        let router = RouterVC()
        if !router.isTwoFactorAuthViewControllers() {
            logout()
        }
    }

    
    private static func configureSDWebImage() {
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024   // 100Mb
        SDImageCache.shared().config.maxCacheAge = 7 * 24 * 60 * 60     // 7 days
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }
    
    private static func setupCropy() {
        guard let cropyConfig = CRYConfiguration.sharedInstance() else { return }
        cropyConfig.shareType = SharedTypeImage
        cropyConfig.origin = "http://www.cropyioslifebox.com"
        cropyConfig.apiKey = "57f38c7d-1762-43e7-9ade-545fed50dd04"
        
        cropyConfig.headerColor = UIColor.lrTealish
        cropyConfig.headerTitleColor = UIColor.white
        
        cropyConfig.cropHeaderColor = UIColor.lrTealish
        cropyConfig.cropHeaderTitleColor = UIColor.white
    }
    
    // MARK: - settings bundle
    //Check original post here: https://medium.com/@abhimuralidharan/adding-settings-to-your-ios-app-cecef8c5497
    
    struct SettingsBundleKeys {
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    
    
    
   
    
    private static func startMenloworks(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        func setupMenloworks() {
            DispatchQueue.toMain {
                #if LIFEBOX
                MPush.setAppKey("TDttInhNx_m-Ee76K35tiRJ5FW-ysLHd")
                #elseif LIFEDRIVE
                MPush.setAppKey("kEB_ZdDGv8Jqs3DZY1uJhxYWKkwDLw8L")
                #endif
                MPush.setServerURL("https://api.xtremepush.com")
                
                
                #if DEBUG
                MPush.setSandboxModeEnabled(true)
                MPush.setDebugModeEnabled(true)
                MPush.setShouldShowDebugLogs(true)
                #endif
                
                MPush.registerMessageResponseHandler({(_ response: MMessageResponse) -> Void in
                    
                    let payload = response.message.payload
                    let payloadAction = payload["action"] as? String
                    
                    debugLog("Payload: \(payload)")
                    switch response.action.type {
                        
                    case .click:
                        debugLog("Menlo Notif Clicked")
                        
                        if PushNotificationService.shared.assignDeepLink(innerLink: payloadAction) {
                            PushNotificationService.shared.openActionScreen()
                            storageVars.deepLink = payloadAction
                        }
                        
                    case .dismiss:
                        debugLog("Menlo Notif Dismissed")
                        
                    case .present:
                        debugLog("Menlo Notif in Foreground")
                        if PushNotificationService.shared.assignDeepLink(innerLink: payloadAction) {
                            PushNotificationService.shared.openActionScreen()
                        }
                    }
                })
                
                MPush.register(forRemoteNotificationTypes: [.alert, .badge, .sound])
                debugLog("AppConfigurator registerMenloworksForPushNotififcations")
                MPush.applicationDidFinishLaunching(options: launchOptions)
                debugLog("AppConfigurator startMenloworks")
            }
        }
        
        if #available(iOS 10, *) {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            UNUserNotificationCenter.current().requestAuthorization(options: options) { _, _ in
                setupMenloworks()
                ///call appendLocalMediaItems either here or in the AppDelegate
                ///application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings)
                ///it depends on iOS version
                
                /// start photos logic after notification permission
                ///MOVED TO CACHE MANAGER TO BE TRIGGERED AFTER ALL REMOTES ARE ADDED
//                MediaItemOperationsService.shared.appendLocalMediaItems(completion: nil)
                LocalMediaStorage.default.askPermissionForPhotoFramework(redirectToSettings: false){ available, status in
                    
                }
            }
        } else {
            setupMenloworks()
        }
        
    }
    
    private static func startUpdateLocation(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let isLocationUpdate = launchOptions?[.location] as? NSNumber, isLocationUpdate.boolValue {
            LocationManager.shared.startUpdateLocation()
        }
    }
}



