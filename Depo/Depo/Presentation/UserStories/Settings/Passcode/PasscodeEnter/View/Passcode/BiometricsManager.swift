//
//  BiometricsManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import LocalAuthentication

typealias AuthenticateHandler = (Bool) -> Void

protocol BiometricsManager {
    var isEnabled: Bool { get set }
    var status: BiometricsStatus { get }
    var biometricsTitle: String { get }
    var isAvailableFaceID: Bool { get }
    func authenticate(reason: String, handler: @escaping AuthenticateHandler)
}

enum BiometricsStatus {
    case available
    case notAvailable
    case notInitialized ///"passcode is enrolled and biometrics not"
}

final class BiometricsManagerImp: BiometricsManager {
    
    private static let isEnabledKey = "isEnabledKey"
    var isEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: BiometricsManagerImp.isEnabledKey) }
        set {
            #if MAIN_APP
            if isEnabled != newValue {
                MenloworksTagsService.shared.onTouchIDSettingsChanged(newValue)
            }
            if newValue {
                MenloworksEventsService.shared.onTouchIDSet()
            }
            #endif
            UserDefaults.standard.set(newValue, forKey: BiometricsManagerImp.isEnabledKey)
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
        } else {
            return .notAvailable
        }
    }
    
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
            return handler(false)
        }
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                handler(success)
            }
        }
    }
}
