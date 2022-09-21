//
//  ApplicationPalette.swift
//  Depo
//
//  Created by Alexander Gurin on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ApplicationPalette {
    
    static var bigRoundButtonFont: UIFont? {
        var fontSize: CGFloat = 22.0
        if (Device.isIpad) {
            fontSize = 30.0
        }
        return UIFont.TurkcellSaturaBolFont(size: fontSize)
    }
    
    static var mediumRoundButtonFont: UIFont? {
        var fontSize: CGFloat = 18.0
        if (Device.isIpad) {
            fontSize = 24.0
        }
        return UIFont.TurkcellSaturaBolFont(size: fontSize)
    }
    
    static var roundedCornersButtonFont: UIFont? {
        var fontSize: CGFloat = 12.0
        if (Device.isIpad) {
            fontSize = 16.0
        }
        return UIFont.TurkcellSaturaBolFont(size: fontSize)
    }
    
    static var noFilesRoundButtonFont: UIFont? {
        var fontSize: CGFloat = 15.4
        if (Device.isIpad) {
            fontSize = 22
        }
        return UIFont.TurkcellSaturaBolFont(size: fontSize)
    }
    
    static var mediumDemiRoundButtonFont: UIFont? {
        var fontSize: CGFloat = Device.isIpad ? 22 : 16.0
        return .appFont(.medium, size: fontSize)
    }
}
