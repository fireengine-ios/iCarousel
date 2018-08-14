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
import Curio_iOS_SDK
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
        emptyEmailUpIfNeed()
        clearTokensIfNeed()
        logoutIfNeed()
        prepareSessionManager()
        setVersionAndBuildNumber()
        configureSDWebImage()
        setupIAPObserver()
        startMenloworks(with: launchOptions)
        setupCropy()
        startCurio(with: launchOptions)
        dropboxManager.start()
        analyticsManager.start()
        
        AppWormholeListener.shared.startListen()
        _ = PushNotificationService.shared.assignNotificationActionBy(launchOptions: launchOptions)
        LocalMediaStorage.default.clearTemporaryFolder()
        
        startUpdateLocation(with: launchOptions)
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
    
    private static func emptyEmailUpIfNeed() {
        if storageVars.emptyEmailUp {
            debugLog("emptyEmailUpIfNeed")
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
        auth.refreshFailedHandler = logout
        
        let sessionManager = SessionManager.customDefault
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
    
    private static func startCurio(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let appLaunchOptions = launchOptions else {
            return
        }
        
        let serverURL = "http://curio.turkcell.com.tr/api/v2"
        
        //let apiKey = "8fb5c84a549711e881e1d5b6432746d5" /// another test
        let apiKey = "cab314f33df2514764664e5544def586"

        #if DEBUG
        let trackingCode = "20AW4ELA"

        #else
        let trackingCode = "KL2XNFIE"
        #endif
        
        
        CurioSDK.shared().startSession(serverURL, apiKey: apiKey, trackingCode: trackingCode, sessionTimeout: 30, periodicDispatchEnabled: true, dispatchPeriod: 5, maxCachedActivitiyCount: 10, loggingEnabled: false, logLevel: 0, fetchLocationEnabled: false, maxValidLocationTimeInterval: 600, appLaunchOptions: appLaunchOptions)
    }
    
    static func stopCurio() {
        CurioSDK.shared().endSession()
    }
    
    private static func startMenloworks(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        func setupMenloworks() {
            DispatchQueue.toMain {
                MPush.setAppKey("TDttInhNx_m-Ee76K35tiRJ5FW-ysLHd")
                MPush.setServerURL("https://turkcell.menloworks.com")
                
                
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
                CoreDataStack.default.appendLocalMediaItems(completion: nil)
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
