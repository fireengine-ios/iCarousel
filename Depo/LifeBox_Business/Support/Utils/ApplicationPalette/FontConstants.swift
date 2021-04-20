//
//  FontConstants.swift
//  Depo
//
//  Created by Alex Developer on 14.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

extension UIFont {
    
    static func TurkcellSaturaDemFont(size: CGFloat = 9) -> UIFont {
        return .systemFont(ofSize: size, weight: .semibold)//UIFont(name: "TurkcellSaturaDem", size: size)!
    }
    
    static func TurkcellSaturaRegFont(size: CGFloat = 9) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)//UIFont(name: "GTAmericaTrial-Rg", size: size)!
    }
    
    static func TurkcellSaturaBolFont(size: CGFloat = 9) -> UIFont {
        return .systemFont(ofSize: size, weight: .bold)//UIFont(name: "TurkcellSaturaBol", size: size)!
    }
    
    static func TurkcellSaturaItaFont(size: CGFloat = 9) -> UIFont {
        return .italicSystemFont(ofSize: size)//UIFont(name: "TurkcellSaturaIta", size: size)!
    }
    
    static func TurkcellSaturaMedFont(size: CGFloat = 9) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)//UIFont(name: "GTAmericaTrial-Md", size: size)!
    }
    
    static func TurkcellSaturaFont(size: CGFloat = 18) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)//UIFont(name: "GTAmericaTrial-Rg", size: size)!
    }
    
    static func GTAmericaStandardRegularFont(size: CGFloat = 18) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)//UIFont(name: "GTAmericaTrial-Rg", size: size)!
    }
    
    static func GTAmericaStandardMediumFont(size: CGFloat = 18) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)//UIFont(name: "GTAmericaTrial-Md", size: size)!
    }
}

