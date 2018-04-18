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

class AppConfigurator {
    
    static let dropboxManager: DropboxManager = factory.resolve()
    static let analyticsManager: AnalyticsService = factory.resolve()
    
    class func applicationStarted(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        AppConfigurator.getRefreshTockenFromOldApplication()
        dropboxManager.start()
        analyticsManager.start()
        AppWormholeListener.shared.startListen()
        
        emptyEmailUpIfNeed()
        
        let urls: AuthorizationURLs = AuthorizationURLsImp()
        let tokenStorage: TokenStorage = factory.resolve()
        
        if tokenStorage.isClearTokens {
            tokenStorage.isClearTokens = false
            tokenStorage.clearTokens()
        }
        
        if !tokenStorage.isRememberMe {
            AuthenticationService().logout(async: false, success: nil)
        }
        
        var auth: AuthorizationRepository = AuthorizationRepositoryImp(urls: urls, tokenStorage: tokenStorage)
        auth.refreshFailedHandler = logout
        
        let sessionManager = SessionManager.default
        sessionManager.retrier = auth
        sessionManager.adapter = auth
        
        setVersionAndBuildNumber()
        configureSDWebImage()
        setupCropy()
        
//        CoreDataStack.default.appendLocalMediaItems {
            startMenloworks(with: launchOptions)
//        }
        
        _ = PushNotificationService.shared.assignNotificationActionBy(launchOptions: launchOptions)
        
        LocalMediaStorage.default.clearTemporaryFolder()
    }
    
    private class func getRefreshTockenFromOldApplication() {
        AppMigrator.migrateFromOldApplicationIfNeed()
        
    }
    
    private class func emptyEmailUpIfNeed() {
        let storageVars: StorageVars = factory.resolve()
        
        if storageVars.emptyEmailUp {
            storageVars.emptyEmailUp = false
            let attemptsCounter = SavingAttemptsCounterByUnigueUserID.emptyEmailCounter
            attemptsCounter.up(limitHandler: {
                AuthenticationService().logout(async: false, success: nil)
            })
        }
    }
    
    class func logout() {
        /// there is no retain circle bcz of singleton
        AuthenticationService().logout {
            DispatchQueue.main.async {
                let router = RouterVC()
                router.setNavigationController(controller: router.onboardingScreen)
            }
        }
    }
    
    class private func configureSDWebImage() {
        SDImageCache.shared().config.maxCacheSize = 100 * 1024 * 1024   // 100Mb
        SDImageCache.shared().config.maxCacheAge = 7 * 24 * 60 * 60     // 7 days
        SDImageCache.shared().config.shouldCacheImagesInMemory = false
    }
    
    class private func setupCropy() {
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
    
    class func setVersionAndBuildNumber() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        UserDefaults.standard.set(build, forKey: "build_preference")
    }
    
    class private func startMenloworks(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        log.debug("AppConfigurator startMenloworks")
        
        let types: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.sound, UIUserNotificationType.badge]
        let notificationTypes = NSInteger(types.rawValue)
        
        DispatchQueue.main.async {
            MPush.register(forRemoteNotificationTypes: MNotificationType(rawValue: notificationTypes))
            MPush.applicationDidFinishLaunching(options: launchOptions)
        }
    }
    
}
