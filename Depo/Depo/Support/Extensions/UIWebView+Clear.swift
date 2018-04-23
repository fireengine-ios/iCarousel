//
//  UIWebView+Clear.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIWebView {
    func clearPage() {
        guard let url = URL(string: "about:blank") else {
            return
        }
        loadRequest(URLRequest(url: url))
    }
}
