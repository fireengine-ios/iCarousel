//
//  BiometricsManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import LocalAuthentication

typealias AuthenticateHandler = (BiometricsAuthenticateResult) -> Void

protocol BiometricsManager {
    var isEnabled: Bool { get set }
    var status: BiometricsStatus { get }
    var biometricsTitle: String { get }
    var isAvailableFaceID: Bool { get }
    func authenticate(reason: String, handler: @escaping AuthenticateHandler)
}

// TODO: rewrite to system codes
//public var kLAErrorAuthenticationFailed: Int32 { get }
//public var kLAErrorUserCancel: Int32 { get }
//public var kLAErrorUserFallback: Int32 { get }
//public var kLAErrorSystemCancel: Int32 { get }
//public var kLAErrorPasscodeNotSet: Int32 { get }
//public var kLAErrorTouchIDNotAvailable: Int32 { get }
//public var kLAErrorTouchIDNotEnrolled: Int32 { get }
//public var kLAErrorTouchIDLockout: Int32 { get }
//public var kLAErrorAppCancel: Int32 { get }
//public var kLAErrorInvalidContext: Int32 { get }
//public var kLAErrorNotInteractive: Int32 { get }
//
//public var kLAErrorBiometryNotAvailable: Int32 { get }
//public var kLAErrorBiometryNotEnrolled: Int32 { get }
//public var kLAErrorBiometryLockout: Int32 { get }

enum BiometricsAuthenticateResult: Int {
    case success = 0
    case notAvailable = 1
    case retryLimitReached = -1
    case cancelledByUser = -2
    case userFallback = -3
    case cancelledBySystem = -4
    case sensorIsLocked = -8
}

enum BiometricsStatus {
    case available
    case notAvailable
    case notInitialized ///"passcode is enrolled and biometrics not"
}

final class BiometricsManagerImp: BiometricsManager {
    
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)
    
    private static let isEnabledKey = "isEnabledKey"
    var isEnabled: Bool {
        get { return defaults?.bool(forKey: BiometricsManagerImp.isEnabledKey) ?? false}
        set {
            defaults?.set(newValue, forKey: BiometricsManagerImp.isEnabledKey)
        }
    }
    
    var status: BiometricsStatus {
        var error: NSError?
        let result = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if result {
            return .available
        /// biometrics are available on device, but is not turn on.
        /// -5, -7 hardcoded, not documented constants to detect it.
        /// may not be working for some devices.
        } else if error?.code == -5 || error?.code == -7 {
            return .notInitialized
        } else { /// err.code == -6 no physical equipment
            
            /// System locks Touch ID after 5 invalid tries.
            /// It says: Biometry is locked out. (error?.code == -8)
            /// Will be locked until the user enters the passcode
            /// Solution: Lock-unlock device by turn off screen and Touch ID will be available.
            return .notAvailable
        }
    }
    
    /// maybe will be need
    // TODO: it is work correct
    // TODO: check without BoolHandler
    // TODO: correct all text for Face ID
    /// https://stackoverflow.com/a/45613341/5893286
    /// https://stackoverflow.com/a/40785158/5893286
    //func isBiometryReady() -> Bool {
    //    let context = LAContext()
    //    var error: NSError?
    //    context.localizedFallbackTitle = ""
    //    if #available(iOS 10.0, *) {
    //        context.localizedCancelTitle = "Enter Using Passcode"
    //    }
    //    
    //    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
    //        return true
    //    }
    //    
    //    var isBiometryReady = false
    //    if error?.code == -8 {
    //        let reason = "TouchID has been locked out due to few fail attemp. Enter iPhone passcode to enable touchID."
    //        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { success, error in
    //            isBiometryReady = false                    
    //        })
    //        isBiometryReady = true
    //    }
    //    return isBiometryReady
    //}

    
    lazy var biometricsTitle: String = {
        isAvailableFaceID ? TextConstants.passcodeFaceID : TextConstants.passcodeTouchID
    }()
    
    /// You need to first call canEvaluatePolicy in order to get the biometry type.
    /// That is, if you're just doing LAContext().biometryType then you'll always get 'none' back
    /// https://forums.developer.apple.com/thread/89043
    var isAvailableFaceID: Bool {
        return Device.isIphoneX
        /// old normal realization
//        let context = LAContext()
//        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
//            return false
//        }
//        if #available(iOS 11.0, *) {
//            return context.biometryType == .faceID
//        } else {
//            return false
//        }
    }
    
    func authenticate(reason: String = TextConstants.passcodeBiometricsDefault, handler: @escaping AuthenticateHandler) {
        if status != .available || !isEnabled {
            return handler(.notAvailable)
        }
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    handler(.success)
                } else if let error = error as NSError? {
                    print("Fingerprint validation failed: \(error.localizedDescription). Code: \(error.code)")
                    if let status = BiometricsAuthenticateResult(rawValue: error.code) {
                        handler(status)
                    } else {
                        handler(.notAvailable)
                    }
                }
            }
        }
    }
}
