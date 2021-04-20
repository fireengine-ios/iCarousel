//
//  MobilePaymentPermissionViewInput.swift
//  Depo
//
//  Created by YAGIZHAN AKDUMAN on 24.02.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol MobilePaymentPermissionViewInput: class {
    func checkBoxDidChange(isChecked: Bool)
    func linkTapped()
    func approveTapped()
}
