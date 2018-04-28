//
//  NavigationBarStyle.swift
//  Depo
//
//  Created by MacBook on 28/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

enum NavigationBarStyle {
    case gradient
    case black
    case clear
    
    var backgroundImage: UIImage? {
        switch self {
        case .gradient: return UIImage(named: "NavigationBarBackground")
        case .black: return UIImage(named: "NavigatonBarBlackBacground")
        case .clear: return UIImage()
        }
    }
}
