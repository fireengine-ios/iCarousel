//
//  FontConstants.swift
//  Depo
//
//  Created by Alex Developer on 14.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

extension UIFont {
    
    static func GTAmericaStandardDemiBoldFont(size: CGFloat) -> UIFont {
        return .GTAmericaStandardMediumFont(size: size)
    }
   
    static func GTAmericaStandardBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "GTAmericaLC-Bd", size: size)!
    }
    
    static func GTAmericaStandardRegularFont(size: CGFloat) -> UIFont {
        return UIFont(name: "GTAmericaLC-Rg", size: size)!
    }
    
    static func GTAmericaStandardMediumFont(size: CGFloat) -> UIFont {
        return UIFont(name: "GTAmericaLC-Md", size: size)!
    }
}

