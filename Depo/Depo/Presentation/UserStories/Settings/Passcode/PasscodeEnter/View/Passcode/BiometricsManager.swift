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
    var isAvailable: Bool { get }
    var isAvailableFaceID: Bool { get }
    func authenticate(reason: String, handler: @escaping AuthenticateHandler)
}

final class BiometricsManagerImp: BiometricsManager {
    
    private static let isEnabledKey = "isEnabledKey"
    var isEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: BiometricsManagerImp.isEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: BiometricsManagerImp.isEnabledKey) }
    }
    
    var isAvailable: Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var isAvailableFaceID: Bool {
        if #available(iOS 11.0, *) {
            return LAContext().biometryType == .faceID
        } else {
            return false
        }
    }
    
    func authenticate(reason: String = TextConstants.passcodeBiometricsDefault, handler: @escaping AuthenticateHandler) {
        if !isAvailable || !isEnabled {
            return handler(false)
        }
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                handler(success)
            }
        }
    }
}
