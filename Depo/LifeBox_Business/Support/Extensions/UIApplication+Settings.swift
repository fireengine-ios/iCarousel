//
//  UIApplication+Settings.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/28/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

extension UIApplication {
    func openSettings() {
        UIApplication.shared.openSafely(URL(string: UIApplicationOpenSettingsURLString))
    }
    func openAppstore() {
        UIApplication.shared.openSafely(URL(string: "itms-apps://itunes.apple.com/app/id\(Device.applicationId)"))
    }
}
