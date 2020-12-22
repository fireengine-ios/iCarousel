//
//  OrientationManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class OrientationManager {
    
    static let shared = OrientationManager()
    
    /// you can set any orientation to lock
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    /// lock orientation and force to rotate device
    func lock(for orientation: UIInterfaceOrientationMask, rotateTo rotateOrientation: UIInterfaceOrientation) {
        orientationLock = orientation
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
}
