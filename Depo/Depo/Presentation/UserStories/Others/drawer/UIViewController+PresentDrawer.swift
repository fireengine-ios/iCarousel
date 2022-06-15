//
//  DrawerViewController+PresentDrawer.swift
//  Depo
//
//  Created by Hady on 6/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAsDrawer(config: (DrawerViewController) -> Void = { _ in },
                         completion: (() -> Void)? = nil,
                         topViewController: UIViewController? = UIApplication.topController()) {
        let drawer = DrawerViewController(content: self)
        config(drawer)
        topViewController?.present(drawer, animated: true, completion: completion)
    }
}
