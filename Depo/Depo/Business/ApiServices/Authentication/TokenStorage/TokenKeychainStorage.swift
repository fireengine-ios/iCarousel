//
//  TokenKeychainStorage.swift
//  Depo
//
//  Created by Oleg on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import KeychainSwift
import WidgetKit
import XCGLogger

final class TokenKeychainStorage: TokenStorage {
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let isRememberMeKey = "isRememberMeKey"
    private let isClearTokensKey = "isClearTokensKey"
    
    private let keychain = KeychainSwift()
    private let degubLogService = DebugLogService()
    
    private (set) var savedAccessToken: String?
    var accessToken: String? {
        get {
            guard let token = keychain.get(accessTokenKey) else {
                return nil
            }
            debugPrint("- accessToken", token)
            return token
        }
        set {
            /// accessibleWhenUnlocked is default for KeychainSwift
            /// You can use .accessibleAfterFirstUnlock if you need your app to access the keychain item while in the background. Note that it is less secure than the .accessibleWhenUnlocked option
            /// https://github.com/evgenyneu/keychain-swift#keychain_item_access
            keychain.set(newValue, forKey: accessTokenKey, withAccess: .accessibleAfterFirstUnlock)
//            if #available(iOS 14, *) {
//                WidgetCenter.shared.reloadAllTimelines()
//            }
            savedAccessToken = newValue
        }
    }
    
    var refreshToken: String? {
        get {
            guard let token = keychain.get(refreshTokenKey) else {
                return nil
            }
            debugPrint("- refreshToken", token)
            return token
        }
        set {
            keychain.set(newValue, forKey: refreshTokenKey, withAccess: .accessibleAfterFirstUnlock)
        }
    }
    
    var isRememberMe: Bool {
        get { return keychain.getBool(isRememberMeKey) ?? false }
        set { keychain.set(newValue, forKey: isRememberMeKey, withAccess: .accessibleAfterFirstUnlock) }
    }
    
    var isClearTokens: Bool {
        get { return keychain.getBool(isClearTokensKey) ?? false }
        set { keychain.set(newValue, forKey: isClearTokensKey, withAccess: .accessibleAfterFirstUnlock) }
    }
    
    init() {
        savedAccessToken = accessToken
    }
    
    func clearTokens(calledMethod: String) {
        debugLog("EXTRA LOG Clear Tokens : \(calledMethod)")
        accessToken = nil
        refreshToken = nil
        isRememberMe = false
    }
    
    let log: XCGLogger = {
        let log = XCGLogger(identifier: XCGLogger.homeWidgetLoggerIdentifier, includeDefaultDestinations: false)
        
        let logPath = Device.documentsFolderUrl(withComponent: XCGLogger.homeWidgetLogFileName)
        
        let autoRotatingFileDestination = AutoRotatingFileDestination(owner: log,
                                                                      writeToFile: logPath,
                                                                      identifier: XCGLogger.homeWidgetLoggerIdentifier,
                                                                      shouldAppend: true,
                                                                      appendMarker: XCGLogger.homeWidgetAppendMarker,
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
    }
}
