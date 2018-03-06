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
            if isEnabled != newValue {
                MenloworksTagsService.shared.onTouchIDSettingsChanged(newValue)
            }
            if newValue {
                MenloworksEventsService.shared.onTouchIDSet()
            }
            UserDefaults.standard.set(newValue, forKey: BiometricsManagerImp.isEnabledKey)
        }
    }
    
    var status: BiometricsStatus {
        var error: NSError?
        let result = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if result {
            return .available
        } else if error?.code == -7 {
            return .notInitialized
        } else {
            return .notAvailable
        }
    }
    
    /// You need to first call canEvaluatePolicy in order to get the biometry type.
    /// That is, if you're just doing LAContext().biometryType then you'll always get 'none' back
    /// https://forums.developer.apple.com/thread/89043
    var isAvailableFaceID: Bool {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return false
        }
        if #available(iOS 11.0, *) {
            return context.biometryType == .faceID
        } else {
            return false
        }
    }
    
    func authenticate(reason: String = TextConstants.passcodeBiometricsDefault, handler: @escaping AuthenticateHandler) {
        if status != .available || !isEnabled {
            return handler(false)
        }
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                handler(success)
            }
        }
    }
}
