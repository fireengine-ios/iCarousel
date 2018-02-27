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
    case notInitialized ///"No fingers are enrolled with Touch ID."
}

final class BiometricsManagerImp: BiometricsManager {
    
    private static let isEnabledKey = "isEnabledKey"
    var isEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: BiometricsManagerImp.isEnabledKey) }
        set {
            if isEnabled != newValue {
                MenloworksTagsService.shared.onTouchIDSettingsChanged(newValue)
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
    
    var isAvailableFaceID: Bool {
        if #available(iOS 11.0, *) {
            /// temp logic for xcode <= 9.1
            return false
            //return LAContext().biometryType == .faceID
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
