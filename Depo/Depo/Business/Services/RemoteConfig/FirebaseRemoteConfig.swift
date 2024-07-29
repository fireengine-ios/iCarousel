//
//  FirebaseRemoteConfig.swift
//  Depo
//
//  Created by Konstantin Studilin on 14.12.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

extension NSNotification.Name {
    static let firebaseRemoteConfigInitialFetchComplete = NSNotification.Name(rawValue: "firebaseRemoteConfigInitialFetchComplete")
}

private struct RemoteConfigKeys {
    static let loginSupportAttempts = "login_support_form_treshold"
    static let signupSupportAttempts = "signup_support_form_treshold"
    static let printOptionEnabled = "new_photoprint_option_enable"
    static let chatbotMenuEnabled = "chatbot_menu_enabled"
    static let contactUsEnabled = "contact_us_enabled"
    static let printOptionEnabledLanguages = "print_option_enabled_languages"
    static let forgotPasswordV2Enabled = "forgot_password_v2_enabled"
    static let googleLoginEnabled = "google_login_enabled"
    static let appleLoginEnabled = "apple_login_enabled"
    static let ocrEnabled = "ocr_enabled"
    static let notificationReadTime = "notification_unread_to_read_time"
    static let lifeboxInstagramEnable = "lifebox_instagram_enable"
    static let lifeboxFacebookEnable = "lifebox_facebook_enable"
    static let lifeboxDropboxEnable = "lifebox_dropbox_enable"
    static let preparePageSizeLimit = "prepare_page_size_limit"
    static let printPhotoQualityMinMB = "Print_Photo_Quality_Min_MB"
    static let timelineEnabled = "yilsonu_timeline_enabled_client"
    static let printMonthlyPhotoSize = "print_monthly_photo_size"
    static let displayConnectAccount = "display_connect_account"
    static let autosyncStartDuration = "autosync_start_duration"
    static let resignupEnabled = "resignup_enabled"
    static let maxSelectCount = "max_select_count"
}

final class FirebaseRemoteConfig {
    static var shared = FirebaseRemoteConfig()
    
    private let remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 10
        #else
        settings.minimumFetchInterval = 60 * 10 // 10 minutes
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "FirebaseRemoteConfigDefaults")
    }
    
    var maxSelectCount: Int {
        let key = RemoteConfigKeys.maxSelectCount
        return remoteConfig.configValue(forKey: key).numberValue.intValue
    }
    
    var resignupEnabled: Bool {
        let key = RemoteConfigKeys.resignupEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    var autosyncStartDuration: Double {
        let key = RemoteConfigKeys.autosyncStartDuration
        return remoteConfig.configValue(forKey: key).numberValue.doubleValue
    }
    
    var displayConnectAccount: Bool {
        let key = RemoteConfigKeys.displayConnectAccount
        return remoteConfig.configValue(forKey: key).boolValue
    }

    var printOptionEnabled: Bool {
        let key = RemoteConfigKeys.printOptionEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    var printMonthlyPhotoSize: Int {
        let key = RemoteConfigKeys.printMonthlyPhotoSize
        return remoteConfig.configValue(forKey: key).numberValue.intValue
    }

    var printOptionEnabledLanguages: [String] {
        let key = RemoteConfigKeys.printOptionEnabledLanguages
        let value = remoteConfig.configValue(forKey: key).stringValue ?? ""
        return value
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map { $0.lowercased() }
    }

    var forgotPasswordV2Enabled: Bool {
        let key = RemoteConfigKeys.forgotPasswordV2Enabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    var googleLoginEnabled: Bool {
        let key = RemoteConfigKeys.googleLoginEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    var notificationReadTime: Int {
        let key = RemoteConfigKeys.notificationReadTime
        return remoteConfig.configValue(forKey: key).numberValue.intValue
    }
    
    var appleLoginEnabled: Bool {
        let key = RemoteConfigKeys.appleLoginEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }

    var ocrEnabled: Bool {
        let key = RemoteConfigKeys.ocrEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    var fetchInstagramMenuEnable: Bool {
        let key = RemoteConfigKeys.lifeboxInstagramEnable
        return remoteConfig.configValue(forKey: key).boolValue
    }
    var fetchFacebookMenuEnable: Bool {
        let key = RemoteConfigKeys.lifeboxFacebookEnable
        return remoteConfig.configValue(forKey: key).boolValue
    }
    var fetchDropboxMenuEnable: Bool {
        let key = RemoteConfigKeys.lifeboxDropboxEnable
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    var fetchPreparePageSizeLimit: Int {
        let key = RemoteConfigKeys.preparePageSizeLimit
        return remoteConfig.configValue(forKey: key).numberValue.intValue
    }
    
    var printPhotoQualityMinMB: String {
        let key = RemoteConfigKeys.printPhotoQualityMinMB
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
    }
    
    var fetchTimelineEnabled: Bool {
        let key = RemoteConfigKeys.timelineEnabled
        return remoteConfig.configValue(forKey: key).boolValue
    }
    
    func fetchAttemptsBeforeSupportOnLogin(completion: @escaping ValueHandler<Int>) {
        let fetchKey = RemoteConfigKeys.loginSupportAttempts
        fetch(key: fetchKey) { [weak self] in
            if let attempts = self?.remoteConfig.configValue(forKey: fetchKey).numberValue.intValue {
                debugLog("fetched \(attempts) attempts for \(fetchKey)")
                completion(attempts)
                return
            }
            
            let attempts = NumericConstants.showSupportViewAttempts
            debugLog("return constant = \(attempts) attempts for \(fetchKey)")
            completion(attempts)
        }
    }
    
    func fetchAttemptsBeforeSupportOnSignup(completion: @escaping ValueHandler<Int>) {
        let fetchKey = RemoteConfigKeys.signupSupportAttempts
        fetch(key: fetchKey) { [weak self] in
            if let attempts = self?.remoteConfig.configValue(forKey: fetchKey).numberValue.intValue {
                debugLog("fetched \(attempts) attempts for \(fetchKey)")
                completion(attempts)
                return
            }
            
            let attempts = NumericConstants.showSupportViewAttempts
            debugLog("return constant = \(attempts) attempts for \(fetchKey)")
            completion(attempts)
        }
    }

    func fetchChatbotMenuEnable(completion: @escaping ValueHandler<Bool>) {
        let fetchKey = RemoteConfigKeys.chatbotMenuEnabled
        fetch(key: fetchKey) {
            let chatMenuEnable = self.remoteConfig.configValue(forKey: fetchKey).boolValue
            debugLog("fetched \(chatMenuEnable) attempts for \(fetchKey)")
            completion(chatMenuEnable)
        }
    }
    
    func fetchContactUsMenuEnable(completion: @escaping ValueHandler<Bool>) {
        let fetchKey = RemoteConfigKeys.contactUsEnabled
        fetch(key: fetchKey) {
            let contatcUsMenuEnable = self.remoteConfig.configValue(forKey: fetchKey).boolValue
            debugLog("fetched \(contatcUsMenuEnable) attempts for \(fetchKey)")
            completion(contatcUsMenuEnable)
        }
    }

    func performInitialFetch() {
        debugLog("performing inital fetch")
        logLastFetchInfo()
        remoteConfig.fetchAndActivate { status, error in
            switch status {
            case .successFetchedFromRemote:
                debugLog("initial fetch: fetched new values")
            case .successUsingPreFetchedData:
                debugLog("initial fetch: using prefetched values")
            case .error:
                debugLog("initial fetch error: \(error?.description ?? "unknown")")
            @unknown default:
                debugLog("unknown status \(status)")
            }

            NotificationCenter.default.post(name: .firebaseRemoteConfigInitialFetchComplete, object: nil)
        }
    }

    private func fetch(key: String, completion: @escaping VoidHandler) {
        debugLog("fetching value for \(key)")
        logLastFetchInfo()
        remoteConfig.fetchAndActivate { status, error in
            switch status {
            case .successFetchedFromRemote:
                debugLog("fetched new value for \(key)")
            case .successUsingPreFetchedData:
                debugLog("using prefetched value for \(key)")
            case .error:
                debugLog("error: \(error?.description ?? "unknown")")
            @unknown default:
                debugLog("unknown status \(status)")
            }
            
            completion()
        }
    }

    private func logLastFetchInfo() {
        if let time = remoteConfig.lastFetchTime {
            debugLog("last fetch time: \(time)")
        }
        debugLog("last fetch status: \(remoteConfig.lastFetchStatus.text)")
    }
}

private extension RemoteConfigFetchStatus {
    var text: String {
        switch self {
        case .noFetchYet:
            return "FIRRemoteConfigFetchStatusNoFetchYet"
        case .success:
            return "FIRRemoteConfigFetchStatusSuccess"
        case .failure:
            return "FIRRemoteConfigFetchStatusFailure"
        case .throttled:
            return "FIRRemoteConfigFetchStatusThrottled"
        @unknown default:
            return "??"
        }
    }
}
