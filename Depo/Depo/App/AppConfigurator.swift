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
    static let analyticsService: AnalyticsService = factory.resolve()

    static func applicationStarted(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        Fabric.with([Crashlytics.self, Answers.self])
        
        /// force arabic language left to right
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        UISwitch.appearance().semanticContentAttribute = .forceLeftToRight
        
        SettingsBundleHelper.setVersionAndBuildNumber()
        SettingsBundleHelper.shared.lifeTechSetup()
        AppResponsivenessService.shared.startMainAppUpdate()
        firstStart()
        clearTokensIfNeed()
        prepareSessionManager()
        configureSDWebImage()
        setupIAPObserver()
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
    
    static func logoutIfNeed() {
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
    
    private static func startUpdateLocation(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if let isLocationUpdate = launchOptions?[.location] as? NSNumber, isLocationUpdate.boolValue {
            LocationManager.shared.startUpdateLocation()
        }
    }
}
