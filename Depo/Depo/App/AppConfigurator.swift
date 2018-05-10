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

final class AppConfigurator {
    
    static let dropboxManager: DropboxManager = factory.resolve()
    static let analyticsManager: AnalyticsService = factory.resolve()
    static let storageVars: StorageVars = factory.resolve()
    static let tokenStorage: TokenStorage = factory.resolve()
    
    static func applicationStarted(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        firstStart()
        emptyEmailUpIfNeed()
        clearTokensIfNeed()
        logoutIfNeed()
        prepareSessionManager()
        setVersionAndBuildNumber()
        configureSDWebImage()
        setupCropy()
        
        startMenloworks(with: launchOptions)
        dropboxManager.start()
        analyticsManager.start()
        AppWormholeListener.shared.startListen()
        _ = PushNotificationService.shared.assignNotificationActionBy(launchOptions: launchOptions)
        LocalMediaStorage.default.clearTemporaryFolder()
        
        startUpdateLocation(with: launchOptions)
    }
    
    private static func firstStart() {
        if storageVars.isAppFirstLaunch {
            log.debug("isAppFirstLaunch")
            storageVars.isAppFirstLaunch = false
            KeychainSwift().clear()
            /// call migrate after Keychain clear
            AppMigrator.migrateAll()
        }
    }
    
    private static func emptyEmailUpIfNeed() {
        if storageVars.emptyEmailUp {
            log.debug("emptyEmailUpIfNeed")
            storageVars.emptyEmailUp = false
            let attemptsCounter = SavingAttemptsCounterByUnigueUserID.emptyEmailCounter
            attemptsCounter.up(limitHandler: {
                AuthenticationService().logout(async: false, success: nil)
            })
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
            log.debug("clearTokensIfNeed")
            tokenStorage.isClearTokens = false
            tokenStorage.clearTokens()
        }
    }
    
    private static func logoutIfNeed() {
        if !tokenStorage.isRememberMe {
            log.debug("logoutIfNeed isRememberMe false")
            AuthenticationService().logout(async: false, success: nil)
        }
    }
    
    private static func prepareSessionManager() {
        let urls: AuthorizationURLs = AuthorizationURLsImp()
        
        var auth: AuthorizationRepository = AuthorizationRepositoryImp(urls: urls, tokenStorage: tokenStorage)
        auth.refreshFailedHandler = logout
        
        let sessionManager = SessionManager.default
        sessionManager.retrier = auth
        sessionManager.adapter = auth
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
    
    private static func setVersionAndBuildNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
    
    private static func startMenloworks(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        MPush.setAppKey("TDttInhNx_m-Ee76K35tiRJ5FW-ysLHd")
        MPush.setServerURL("https://turkcell.menloworks.com")
        
        MPush.setDebugModeEnabled(true)
        MPush.setShouldShowDebugLogs(true)
        
        MPush.registerMessageResponseHandler({(_ response: MMessageResponse) -> Void in
            
            log.debug("Payload: \(response.message.payload)")
            switch response.action.type {
                
            case MActionType.click:
                log.debug("Menlo Notif Clicked")
                if PushNotificationService.shared.assignDeepLink(innerLink: (response.message.payload["action"] as! String)){
                    PushNotificationService.shared.openActionScreen()
                }
                
            case MActionType.dismiss:
                log.debug("Menlo Notif Dismissed")
                
            case MActionType.present:
                log.debug("Menlo Notif in Foreground")
                if PushNotificationService.shared.assignDeepLink(innerLink: (response.message.payload["action"] as! String)){
                    PushNotificationService.shared.openActionScreen()
                }
                
            }
        })
        
        DispatchQueue.main.async {
            MPush.applicationDidFinishLaunching(options: launchOptions)
            log.debug("AppConfigurator startMenloworks")
        }
    }
    
    
    static func registerMenloworksForPushNotififcations() {
        DispatchQueue.main.async {
            MPush.register(forRemoteNotificationTypes: [.alert, .badge, .sound])
            log.debug("AppConfigurator registerMenloworksForPushNotififcations")
        
        }
    }
    
    private static func startUpdateLocation(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let isLocationUpdate = launchOptions?[.location] as? NSNumber, isLocationUpdate.boolValue {
            LocationManager.shared.startUpdateLocation()
        }
    }
}
