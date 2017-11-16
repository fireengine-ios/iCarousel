//
//  TouchIdManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/4/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import LocalAuthentication

final class TouchIdManager {
    
    private static let isEnabledTouchIdKey = "isEnabledTouchIdKey"
    var isEnabledTouchId: Bool {
        get { return UserDefaults.standard.bool(forKey: TouchIdManager.isEnabledTouchIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: TouchIdManager.isEnabledTouchIdKey) }
    }
    
    var isAvailable: Bool {
        return LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var isAvailableFaceID: Bool {
        if #available(iOS 11.0, *) {
            return LAContext().biometryType == .typeFaceID
        } else {
            return false
        }
    }
    
    func authenticate(reason: String = "For passcode", handler: @escaping (Bool) -> Void) {
        if !isAvailable || !isEnabledTouchId {
            return handler(false)
        }
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            DispatchQueue.main.async {
                handler(success)
            }
        }
    }
}
