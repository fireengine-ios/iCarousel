//
//  HeaderContainingViewControllerChild.swift
//  Depo
//
//  Created by Hady on 4/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

protocol HeaderContainingViewControllerChild: AnyObject {
    var scrollViewForHeaderTracking: UIScrollView? { get }
}

extension HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? { nil }
}

extension UIViewController {
    var headerContainingViewController: HeaderContainingViewController? {
        var parent = self.parent
        while parent != nil {
            if let headerContainingViewController = parent as? HeaderContainingViewController {
                return headerContainingViewController
            }
            parent = parent?.parent
        }

        return nil
    }
}
