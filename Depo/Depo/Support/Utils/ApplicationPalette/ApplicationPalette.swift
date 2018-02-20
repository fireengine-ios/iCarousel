//
//  ApplicationPalette.swift
//  Depo
//
//  Created by Alexander Gurin on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

struct ColorConstants {
    static let whiteColor = UIColor.white
    static let blueColor = UIColor(red: 68/255, green: 204/255, blue: 208/255, alpha: 1)
    static let yellowColor = UIColor(red: 1, green: 240/255, blue: 149/255, alpha: 1)
    static let switcherGrayColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
    static let switcherGreenColor = UIColor(red: 68/255, green: 219/255, blue: 94/255, alpha: 1)
    static let textGrayColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)
    static let textLightGrayColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 0.5)
    static let greenColor = UIColor(red: 80/255, green: 227/255, blue: 119/255, alpha: 1)
    static let lightGrayColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1)
    static let selectedCellBlueColor = UIColor(red: 80/255, green: 220/255, blue: 220/255, alpha: 0.2)
    static let selectedBottomBarButtonColor = UIColor(red: 255/255, green: 171/255, blue: 141/255, alpha: 1)
    static let fileGreedCellColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    static let darcBlueColor = UIColor(red: 5/255, green: 45/255, blue: 67/255, alpha: 1)
    static let searchBarColor = UIColor(red: 3/255, green: 3/255, blue: 3/255, alpha: 0.09)
    static let searchShadowColor = UIColor(red: 29/255, green: 29/255, blue: 29/255, alpha: 0.49)
    static let darkText = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
    static let lightText = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 1)
    static let activityTimelineDraws = UIColor(red: 6/255, green: 44/255, blue: 66/255, alpha: 1)
    static let lightPeach = UIColor(red: 255/255, green: 226/255, blue: 198/255, alpha: 1)
    static let yellowButtonColor = UIColor(red: 1, green: 199/255, blue: 77/255, alpha: 1)
    static let grayTabBarButtonsColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
    static let textOrange = UIColor(red: 255/255, green: 160/255, blue: 10/255, alpha: 1)
    static let darkBorder = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
    static let orangeBorder = UIColor(red: 249/255, green: 206/255, blue: 107/255, alpha: 1)
    static let oldieFilterColor = UIColor(red: 1, green: 230.0/255.0, blue: 0, alpha: 0.4)
    
    static let orangeGradientStart = UIColor(red: 255/255, green: 177/255, blue: 33/255, alpha: 1)
    static let orangeGradientEnd = UIColor(red: 255/255, green: 183/255, blue: 116/255, alpha: 1)
    static let greenGradientStart = UIColor(red: 92/255, green: 195/255, blue: 195/255, alpha: 1)
    static let greenGradientEnd = UIColor(red: 77/255, green: 218/255, blue: 218/255, alpha: 1)
    static let redGradientStart = UIColor(red: 159/255, green: 4/255, blue: 27/255, alpha: 1)
    static let redGradientEnd = UIColor(red: 245/255, green: 81/255, blue: 95/255, alpha: 1)
    
    static let bottomViewGrayColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
}

extension UIColor {
    
    class var lrTealish: UIColor {
        return UIColor(red: 51.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
    }
    
    class var lrTiffanyBlue: UIColor {
        return UIColor(red: 96.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    }
    
    class var lrMango: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 177.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)
    }
    
    class var lrApricot: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 183.0 / 255.0, blue: 116.0 / 255.0, alpha: 1.0)
    }
    
    class var lrTealishTwo: UIColor {
        return UIColor(red: 68.0 / 255.0, green: 205.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
    }
    
    class var lrMintGreen: UIColor {
        return UIColor(red: 41.0 / 255.0, green: 240.0 / 255.0, blue: 135.0 / 255.0, alpha: 1.0)
    }
    
    class var lrCryonBlue: UIColor {
        return UIColor(red: 2.0 / 255.0, green: 203.0 / 255.0, blue: 210.0 / 255.0, alpha: 1.0)
    }
    
    class var lrRedOrange: UIColor {
        return UIColor(red: 239.0 / 255.0, green: 70.0 / 255.0, blue: 84.0 / 255.0, alpha: 1.0)
    }
    
    class var lrYellowSun: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 197.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
    }
    
    class var lrSkinTone: UIColor {
        return UIColor(red: 254.0 / 255.0, green: 247.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    }
    
}

// Text Font

extension UIFont {
    
    static func TurkcellSaturaDemFont(size:CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaDem", size: size)!
    }
    
    static func TurkcellSaturaRegFont(size:CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaReg", size: size)!
    }
    
    static func TurkcellSaturaBolFont(size:CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaBol", size: size)!
    }
    
    static func TurkcellSaturaItaFont(size:CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaIta", size: size)!
    }
    
    static func TurkcellSaturaMedFont(size:CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaMed", size: size)!
    }
}


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
}
