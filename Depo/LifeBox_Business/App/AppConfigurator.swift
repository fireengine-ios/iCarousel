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
import DigitalGate

final class AppConfigurator {
    
    static let analyticsManager: AnalyticsService = factory.resolve()
    static let storageVars: StorageVars = factory.resolve()
    static let tokenStorage: TokenStorage = factory.resolve()
    static let analyticsService: AnalyticsService = factory.resolve()

    static func applicationStarted(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
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
        analyticsManager.start()
        
        AppWormholeListener.shared.startListen()
        _ = PushNotificationService.shared.assignNotificationActionBy(launchOptions: launchOptions)
        LocalMediaStorage.default.clearTemporaryFolder()
        
        AuthoritySingleton.shared.checkNewVersionApp()
    }
    
    private static func firstStart() {
        if storageVars.isAppFirstLaunch {
            debugLog("isAppFirstLaunch")
            storageVars.isAppFirstLaunch = false
            KeychainCleaner().clear()
            /// call migrate after Keychain clear
            AppMigrator.migrateAll()
        }
    }
    
    static func logout() {
        /// there is no retain circle bcz of singleton
        AuthenticationService().logout {
            DispatchQueue.main.async {
                let router = RouterVC()
                let navC = UINavigationController(rootViewController: router.loginScreen!)
                router.setNavigationController(controller: navC)
            }
        }
    }
    
    private static func clearTokensIfNeed() {
        if tokenStorage.isClearTokens {
            debugLog("clearTokensIfNeed")
            if tokenStorage.isLoggedInWithFastLogin {
                let loginCoordinator = DGLoginCoordinator(nil)
                loginCoordinator.appID = Device.isIpad ? TextConstants.NotLocalized.ipadFastLoginAppIdentifier : TextConstants.NotLocalized.iPhoneFastLoginAppIdentifier
                loginCoordinator.environment = .prp
                loginCoordinator.logout()
                printLog("[AppConfigurator] FL logout")
            }
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
    
    
    // MARK: - settings bundle
    //Check original post here: https://medium.com/@abhimuralidharan/adding-settings-to-your-ios-app-cecef8c5497
    
    struct SettingsBundleKeys {
        static let BuildVersionKey = "build_preference"
        static let AppVersionKey = "version_preference"
    }
    
}
