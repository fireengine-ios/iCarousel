//
//  AppDelegate.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import FirebaseCrashlytics
import FBSDKCoreKit
import SDWebImage
import XCGLogger
import Adjust
import Netmera
import UserNotifications
import KeychainSwift
import WidgetKit
import CoreSpotlight
import FirebaseDynamicLinks
import GoogleSignIn
import AGConnectCore
import AGConnectAppLinking
import Netmera

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

func debugLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    log.debug(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([string]))
}

func printLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
    print(string)
    log.debug(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    Crashlytics.crashlytics().log(format: "%@", arguments: getVaList([string]))
}

func fatalLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) -> Never {
    debugLog(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    fatalError(string)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.orientationLock
    }
    
    
    private lazy var dropboxManager: DropboxManager = factory.resolve()
    private lazy var spotifyService: SpotifyRoutingService = factory.resolve()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var biometricsManager: BiometricsManager = factory.resolve()
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()

    @available(iOS 13.0, *)
    var backgroundSyncService: BackgroundSyncService {
        get {
            return BackgroundSyncService.shared
        }
    }
    
    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = {
        return DeeplinkCoordinator(handlers: [
            BrandAmbassadorDeeplinkHandler(root: RouterVC()),
        ])
    }()

    var window: UIWindow?
    var watchdog: Watchdog?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let coreDataStack: CoreDataStack = factory.resolve()

        startCoreDataSafeServices(with: application, options: launchOptions)
        
        APILogger.shared.startLogging()

        ///call debugLog only if the Crashlytics is already initialized
        debugLog("AppDelegate didFinishLaunchingWithOptions")
        
        let router = RouterVC()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = InitializingViewController()
        self.window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            debugLog("BG! Registeration")
            self.backgroundSyncService.registerLaunchHandlers()
            
        }
        
        coreDataStack.setup { [weak self] in
            guard let self = self else {
                return
            }

            DispatchQueue.main.async {
                AppConfigurator.logoutIfNeed()
                
                self.window?.rootViewController = router.vcForCurrentState()
                self.window?.isHidden = false
                
            }
        }
        
        startListeninAppLink()
        checkNewAppVersion()
        
        return true
    }
    
    private func startCoreDataSafeServices(with application: UIApplication, options: [UIApplication.LaunchOptionsKey: Any]?) {
        DispatchQueue.setupMainQueue()
    
        #if DEBUG
            watchdog = Watchdog(threshold: 0.05, strictMode: false)
        #endif
        
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("Documents: \(documents)")
        
        SharedGroupCoreDataStack.shared.setup {
            debugLog("SharedGroupCoreDataStack setup is completed")
        }
    
        setupPushNotifications(with: options)
        AppConfigurator.applicationStarted(with: options)
        
        ContactSyncSDK.doPeriodicSync()
        
        passcodeStorage.systemCallOnScreen = false
        
        AppLinkUtility.fetchDeferredAppLink { url, error in
            if let url = url {
                UIApplication.shared.openSafely(url)
            } else {
                debugLog("Received error while fetching deferred app link \(String(describing: error))")
            }
        }
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: options)
    }
    
    private func setupPushNotifications(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // required setup order
        // 1. subscribe to notification delegate
        // 2. Netmera SDK setup
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { _, _ in
            Netmera.requestPushNotificationAuthorization(forTypes: [.alert, .badge, .sound])
            AnalyticsPermissionNetmeraEvent.sendNotificationPermissionNetmeraEvents()
        }
        UNUserNotificationCenter.current().delegate = self
        //AnalyticsService.startNetmera()
        NetmeraService.startNetmera()
        debugLog("AppDelegate setupPushNotifications setuped")
    }
    
    /// iOS 9+
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("I have received a URL through a custom sceme! \(url.absoluteString)")

        if AGCAppLinking.instance().openDeepLinkURL(url) {
            if url.absoluteString.contains("publicToken") {
                storageVars.isAppFirstLaunchForPublicSharedItems = true
            }
            return true
        }

        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            storageVars.isAppFirstLaunchForPublicSharedItems = true
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        }
        
        Adjust.appWillOpen(url)
        
        if let urlHost = url.host {
            if PushNotificationService.shared.assignDeepLink(innerLink: urlHost, options: url.queryParameters) {
                PushNotificationService.shared.openActionScreen()
            }
        }
        
        if deeplinkCoordinator.handleURL(url) {
            return true
        }
        
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        } else if dropboxManager.handleRedirect(url: url) {
            return true
        } else if spotifyService.handleRedirectUrl(url: url) {
            return true
        }
        
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        return false
    }
    
    private var firstResponder: UIResponder?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        debugLog("AppDelegate applicationDidEnterBackground")
        
        
        if #available(iOS 13.0, *) {
            debugLog("BG! AppDelegate applicationDidEnterBackground")
            backgroundSyncService.scheduleProcessingSync()
            backgroundSyncService.scheduleRefreshSync()
        }
        
        BackgroundTaskService.shared.beginBackgroundTask()

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
        debugLog("AppDelegate applicationWillEnterForeground")
        let isLoggedIn = tokenStorage.refreshToken != nil
        if isLoggedIn && BackgroundTaskService.shared.appWasSuspended {
            debugLog("App was suspended")
            CacheManager.shared.stopRemotesActualizeCache()
            CacheManager.shared.actualizeCache()
        } else if isLoggedIn {
            SyncServiceManager.shared.update()
        }
        
        
        ContactSyncSDK.doPeriodicSync()
        
        FirebaseRemoteConfig.shared.performInitialFetch()
    }
    
    func showPasscodeIfNeedInBackground() {
        let state = ApplicationStateHelper.shared.safeApplicationState
        if state == .background || state == .inactive {
            showPasscodeIfNeed()
        }
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
        let passcodeController = PasscodeEnterViewController.with(flow: .validate, navigationTitle: TextConstants.passcodeLifebox)
        passcodeController.success = {
            topVC?.dismiss(animated: true, completion: {
                self.firstResponder?.becomeFirstResponder()
            })
        }
        
        let navVC = NavigationController(rootViewController: passcodeController)
        navVC.modalPresentationStyle = .overFullScreen
        
        topVC?.present(navVC, animated: false, completion: nil)
    }
    
    private func checkPasscodeIfNeed() {
        if passcodeStorage.isEmpty {
            return
        }
        
        let topVC = UIApplication.topController()
        if let vc = topVC as? PasscodeEnterViewController {
            if !vc.passcodeManager.finishBiometrics {
                vc.passcodeManager.authenticateWithBiometrics()
            } else if !vc.passcodeManager.successFinishBiometrics {
                vc.becomeResponder()
            }
        }
    }
    
    private func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            debugLog("Dynamic link object has no url")
            return
        }
        
        if let publicToken = url.lastPathComponent.split(separator: "&").first {
            if PushNotificationService.shared.assignDeepLink(innerLink: PushNotificationAction.saveToMyLifebox.rawValue,
                                                             options: [DeepLinkParameter.publicToken.rawValue: publicToken]) {
                debugLog("Should open Action Screen")
                PushNotificationService.shared.openActionScreen()
            }
            debugLog("Your incoming link parameter is \(url.absoluteString)")
        }
        
    }
    
    private func startListeninAppLink() {
        AGCInstance.startUp()
        
        AGCAppLinking.instance().handle { (link, error) in
            if let deepLink = link {
                self.handleIncomingApplink(deepLink)
            }
        }
    }
    
    private func checkNewAppVersion() {
        ///LB-1136
        if AuthoritySingleton.shared.isNewAppVersion {
            if let urlString = UIPasteboard.general.string,
               let url = URL(string: urlString.replacingOccurrences(of: "/#!", with: "")),
               let publicToken = url["publicToken"] {
                if PushNotificationService.shared.assignDeepLink(innerLink: PushNotificationAction.saveToMyLifebox.rawValue,
                                                                 options: [DeepLinkParameter.publicToken.rawValue: publicToken]) {
                    debugLog("Should open Action Screen")
                    PushNotificationService.shared.openActionScreen()
                }
                debugLog("DynamicLink app update url readed: \(urlString)")
            }
        }
    }
    
    private func handleIncomingApplink(_ appLink: AGCResolvedLink) {
        if let url = URL(string: appLink.deepLink) {
            if url.absoluteString.contains("shr") { ///public share flow
                if let publicToken = url.lastPathComponent.split(separator: "&").first {
                    if PushNotificationService.shared.assignDeepLink(innerLink: PushNotificationAction.saveToMyLifebox.rawValue,
                                                                     options: [DeepLinkParameter.publicToken.rawValue: publicToken]) {
                        debugLog("Should open Action Screen")
                        PushNotificationService.shared.openActionScreen()
                    }
                }
            } else if url.absoluteString.contains("paycell") { ///paycell campaign flow
                if let campaign = url.lastPathComponent.split(separator: "&").first,
                   let refererToken = url.lastPathComponent.components(separatedBy: "=").last {
                    PushNotificationService.shared.resolveUnknownAction(actionString: String(campaign), refererToken: refererToken)
                }
            } else {
                debugLog("Applink url couldn't be parsed")
            }
            
            debugLog("Your incoming link parameter is \(url.absoluteString)")
        } else {
            debugLog("Applink object has no deeplink")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        debugLog("AppDelegate applicationWillResignActive")
        
        showPasscodeIfNeed()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        debugLog("AppDelegate applicationDidBecomeActive")
        checkPasscodeIfNeed()
        AppEvents.activateApp()
        overrideApplicationThemeStyle()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        debugLog("AppDelegate applicationWillTerminate")
        
        if !tokenStorage.isRememberMe {
            SyncServiceManager.shared.stopSync()
            AutoSyncDataStorage().clear()
        }
        
        storageVars.publicSharedItemsToken = nil
        WidgetService.shared.notifyWidgetAbout(status: .stopped)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        UserDefaults.standard.synchronize()
        
        player.stop()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        debugLog("AppDelegate applicationDidReceiveMemoryWarning")

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
        debugLog("AppDelegate didRegisterForRemoteNotificationsWithDeviceToken")
        AnalyticsPermissionNetmeraEvent.sendNotificationPermissionNetmeraEvents()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugLog("AppDelegate didFailToRegisterForRemoteNotificationsWithError")
        AnalyticsPermissionNetmeraEvent.sendNotificationPermissionNetmeraEvents()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        self.application(application, didReceiveRemoteNotification: userInfo) { result in
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugLog("AppDelegate didReceiveRemoteNotification")
        
        AppEvents.logPushNotificationOpen(userInfo)
        
        // track receiving TBMatik Push notifications
        if let pushType = Netmera.recentPushObject()?.customDictionary[PushNotificationParameter.pushType.rawValue] as? String,
            pushType == PushNotificationAction.tbmatic.rawValue {
            analyticsService.logScreen(screen: .tbmatikPushNotification)
            analyticsService.trackDimentionsEveryClickGA(screen: .tbmatikPushNotification)
        }

        // Handling Silent Push notifications
        if let pushType = Netmera.recentPushObject()?.customDictionary[PushNotificationParameter.pushType.rawValue] as? String,
            pushType == PushNotificationAction.silent.rawValue {
            SilentPushApiService().uploadLog()
        }
    }

    func overrideApplicationThemeStyle() {
        if #available(iOS 13.0, *) {
            if let isDarkModeEnabled = storageVars.isDarkModeEnabled {
                if isDarkModeEnabled {
                    window?.overrideUserInterfaceStyle = .dark
                } else {
                    window?.overrideUserInterfaceStyle = .light
                }
            } else {
                window?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    //MARK: Adjust
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if userActivity.activityType == CSSearchableItemActionType {
            guard let albumUUID = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                  tokenStorage.accessToken != nil else {
                return true
            }
            if PushNotificationService.shared.assignDeepLink(innerLink: PushNotificationAction.albumDetail.rawValue,
                                                             options: [DeepLinkParameter.albumUUID.rawValue: albumUUID]) {
                debugLog("Should open Action Screen")
                PushNotificationService.shared.openActionScreen()
            }
        }

        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            if PushNotificationService.shared.assignUniversalLink(url: url) {
                PushNotificationService.shared.openActionScreen()
                return true
            }
            
            Adjust.appWillOpen(url)
                
            if let oldURL = Adjust.convertUniversalLink(url, scheme: SharedConstants.applicationQueriesSchemeShort) {
                debugLog("Adjust old path :\(oldURL.path)")
                if let host = oldURL.host {
                    debugLog("Adjust old host :\(host)")
                    
                    if userActivity.userInfo?.count == 0 && host == PushNotificationAction.packages.rawValue {
                        if let data = oldURL.queryParameters["affiliate"] as? String {
                            let result = ["affiliate" : data]
                            if PushNotificationService.shared.assignDeepLink(innerLink: host, options: result) {
                                PushNotificationService.shared.openActionScreen()
                            }
                        }
                    }

                    
                    if userActivity.userInfo?.count != 0 && PushNotificationService.shared.assignDeepLink(innerLink: host, options: userActivity.userInfo) {
                        debugLog("Should open Action Screen")
                        PushNotificationService.shared.openActionScreen()
                    }
                }
            }
        }
        
        if let incomingUrl = userActivity.webpageURL {
            if AGCAppLinking.instance().continueUserActivity(userActivity) {
                storageVars.isAppFirstLaunchForPublicSharedItems = false
                return true
            }

            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingUrl) { (dynamicLink, error) in
                guard error == nil else { return }
                if let dynamicLink = dynamicLink {
                    self.storageVars.isAppFirstLaunchForPublicSharedItems = false
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            if linkHandled {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugLog("userNotificationCenter didReceive response")

        if let options = Netmera.recentPushObject()?.customDictionary ?? response.notification.request.content.userInfo[PushNotificationParameter.netmeraParameters.rawValue] as? [AnyHashable: Any] {
            debugLog("userNotificationCenter try to handle Netmera push object")
            if PushNotificationService.shared.assignNotificationActionBy(launchOptions: options) {
                PushNotificationService.shared.openActionScreen()
                completionHandler()
                return
            }
        } else {
            debugLog("userNotificationCenter Netmera push object is empty")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
