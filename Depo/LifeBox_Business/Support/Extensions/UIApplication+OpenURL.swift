//
//  UIApplication+OpenURL.swift
//  Depo
//
//  Created by Konstantin on 7/30/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


extension UIApplication {
    @discardableResult
    func openSafely(_ url: URL?, options: [String: Any] = [:], completion: ((Bool) -> Void)? = nil) -> Bool {
        guard let url = url, self.canOpenURL(url) else {
            return false
        }
        
        UIApplication.shared.open(url, options: options, completionHandler: completion)
        return true
    }
}
