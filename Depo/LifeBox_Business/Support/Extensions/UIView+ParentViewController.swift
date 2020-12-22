//
//  UIView+ParentViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 5/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

extension UIView {
    
    func findParenViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findParenViewController()
        } else {
            return nil
        }
    }
}
   
