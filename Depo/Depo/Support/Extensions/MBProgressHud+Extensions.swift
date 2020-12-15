//
//  MBProgressHud+Extensions.swift
//  Depo
//
//  Created by Andrei Novikau on 9.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import MBProgressHUD

extension MBProgressHUD {
    
    static func hideAllHUDs(for view: UIView, animated: Bool) {
        let views = allHUDs(for: view)
        views.forEach {
            $0.removeFromSuperViewOnHide = true
            $0.hide(animated: animated)
        } 
    }
    
    static func allHUDs(for view: UIView) -> [MBProgressHUD] {
        return view.subviews.compactMap { $0 as? MBProgressHUD }
    }
}
