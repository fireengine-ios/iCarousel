//
//  ColorConstants.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum AppColor {

    // MARK: NavigationBar
    case navigationBarBackground
    case navigationBarTitle
    case navigationBarIcons
    case navigationBarBackgroundBlack
    case navigationBarTitleBlack
    case navigationBarIconsBlack

    // MARK: TabBar
    case tabBarTint
    case tabBarTintSelected

    case primaryBackground
    case secondaryBackground
    case cellShadow
    case itemSeperator
    case contactsBorderColor
    case lrTealishAndWhite
    case whiteAndLrTealish
    case marineTwoAndWhite
    case blackColor
    case navyAndWhite
    case marineFourAndWhite
    case marineTwoAndTealish
    case whiteAndMarineTwo
    case activityTimelineGray
    case darkBlueAndTealish
    case textPlaceholderColor
    case blackAndLrTealish
    case blackAndOrange
    case hashtagBackground
    case billoGrayAndWhite
    case darkBlueAndBilloBlue
    case popupGray
    case blueAndGray
    case darkTextAndLightGray
    case lightPeachBackground
    case inactiveButtonColor
    case lrTealishAndDarkBlue
    case blueGreenAndWhite
    case popUpBackground

    var color: UIColor? {
        return UIColor(named: String(describing: self))
    }
}

func color(_ color: AppColor) -> UIColor {
    guard let uiColor = color.color else {
        assertionFailure()
        return UIColor()
    }

    return uiColor
}

// TODO: Facelift: remove all legacy colors
struct ColorConstants {
    static let whiteColor = UIColor(named: "whiteColor")!
    static let blueColor = UIColor(named: "blueColor")!
    static let lightBlueColor = UIColor(named: "lightBlueColor")!
    static let yellowColor = UIColor(named: "yellowColor")!
    static let switcherGrayColor = UIColor(named: "switcherGrayColor")!
    static let switcherGreenColor = UIColor(named: "switcherGreenColor")!
    static let textGrayColor = UIColor(named: "textGrayColor")!
    static let textLightGrayColor = UIColor(named: "textLightGrayColor")!
    static let greenColor = UIColor(named: "greenColor")!
    static let lightGrayColor = UIColor(named: "lightGrayColor")!
    static let profileGrayColor = UIColor(named: "profileGrayColor")!
    static let selectedCellBlueColor = UIColor(named: "selectedCellBlueColor")!
    static let selectedBottomBarButtonColor = UIColor(named: "selectedBottomBarButtonColor")!
    static let fileGreedCellColor = UIColor(named: "fileGreedCellColor")!
    static let fileGreedCellColorSecondary = UIColor(named: "fileGreedCellColorSecondary")!
    static let darkBlueColor = UIColor(named: "darkBlueColor")!
    static let searchBarColor = UIColor(named: "searchBarColor")!
    static let searchShadowColor = UIColor(named: "searchShadowColor")!
    static let darkText = UIColor(named: "darkText")!
    static let lightText = UIColor(named: "lightText")!
    static let placeholderGrayColor = UIColor(named: "placeholderGrayColor")!
    static let activityTimelineDraws = UIColor(named: "activityTimelineDraws")!
    static let lightPeach = UIColor(named: "lightPeach")!
    static let yellowButtonColor = UIColor(named: "yellowButtonColor")!
    static let grayTabBarButtonsColor = UIColor(named: "grayTabBarButtonsColor")!
    static let textOrange = UIColor(named: "textOrange")!
    static let darkBorder = UIColor(named: "darkBorder")!
    static let orangeBorder = UIColor(named: "orangeBorder")!
    static let oldieFilterColor = UIColor(named: "oldieFilterColor")!
    static let bottomViewGrayColor = UIColor(named: "bottomViewGrayColor")!
    static let blackForLanding = UIColor(named: "blackForLanding")!
    static let darkGrayTransperentColor = UIColor(named: "darkGrayTransperentColor")!
    static let lightGray = UIColor(named: "lightGray")!
    static let orangeGradientStart = UIColor(named: "orangeGradientStart")!
    static let orangeGradientEnd = UIColor(named: "orangeGradientEnd")!
    static let greenGradientStart = UIColor(named: "greenGradientStart")!
    static let greenGradientEnd = UIColor(named: "greenGradientEnd")!
    static let redGradientStart = UIColor(named: "redGradientStart")!
    static let redGradientEnd = UIColor(named: "redGradientEnd")!
    static let darkRed = UIColor(named: "darkRed")!
    static let photoCell = UIColor(named: "photoCell")!
    static let lrTiffanyBlueGradient = UIColor(named: "lrTiffanyBlueGradient")!
    static let orangeGradient = UIColor(named: "orangeGradient")!
    static let removeConnection = UIColor(named: "removeConnection")!
    static let connectedAs = UIColor(named: "connectedAs")!
    static let errorOrangeGradientStart = UIColor(named: "errorOrangeGradientStart")!
    static let errorOrangeGradientEnd = UIColor(named: "errorOrangeGradientEnd")!
    static let alertBlueGradientStart = UIColor(named: "alertBlueGradientStart")!
    static let alertBlueGradientEnd = UIColor(named: "alertBlueGradientEnd")!
    static let alertOrangeAndBlueGradientStart = UIColor(named: "alertOrangeAndBlueGradientStart")!
    static let alertOrangeAndBlueGradientEnd = UIColor(named: "alertOrangeAndBlueGradientEnd")!
    static let subjectPickerBackgroundColor = UIColor(named: "subjectPickerBackgroundColor")!
    static let toolbarTintColor = UIColor(named: "toolbarTintColor")!
    static let buttonTintColor = UIColor(named: "buttonTintColor")!
    static let closeIconButtonColor = UIColor(named: "closeIconButtonColor")!
    static let cloudyBlue = UIColor(named: "cloudyBlue")!
    static let blueGrey = UIColor(named: "blueGrey")!
    static let coolGrey = UIColor(named: "coolGrey")!
    static let choosenSelectedButtonColor = UIColor(named: "choosenSelectedButtonColor")!
    static let lighterGray = UIColor(named: "lighterGray")!
    static let darkTintGray = UIColor(named: "darkTintGray")!
    static let textDisabled = UIColor(named: "textDisabled")!
    static let charcoalGrey = UIColor(named: "charcoalGrey")!
    static let marineTwo = UIColor(named: "marineTwo")!
    static let marineFour = UIColor(named: "marineFour")!
    static let tealishThree = UIColor(named: "tealishThree")!
    static let tealBlue = UIColor(named: "tealBlue")!
    static let seaweed = UIColor(named: "seaweed")!
    static let blueGreen = UIColor(named: "blueGreen")!
    static let lightTeal = UIColor(named: "lightTeal")!
    static let apricotTwo = UIColor(named: "apricotTwo")!
    static let rosePink = UIColor(named: "rosePink")!
    static let backgroundViewColor = UIColor(named: "backgroundViewColor")!
    static let billoBlue = UIColor(named: "billoBlue")!
    static let billoDarkBlue = UIColor(named: "billoDarkBlue")!
    static let billoGray = UIColor(named: "billoGray")!
    static let stickerBorderColor = UIColor(named: "stickerBorderColor")!
    static let profileLightGray = UIColor(named: "profileLightGray")!
    static let cardBorderOrange = UIColor(named: "cardBorderOrange")!
    static let linkBlack = UIColor(named: "linkBlack")!
    static let snackbarGray = UIColor(named: "snackbarGray")!
    static let duplicatesGray = UIColor(named: "duplicatesGray")!
    static let navy = UIColor(named: "navy")!
    static let photoEditBackgroundColor = UIColor(named: "photoEditBackgroundColor")!
    static let photoEditSliderColor = UIColor(named: "photoEditSliderColor")!
    static let greenyBlue = UIColor(named: "greenyBlue")!
    static let tbMatikBlurColor = UIColor(named: "tbMatikBlurColor")!
    static let aquaMarineTwo = UIColor(named: "aquaMarineTwo")!
    static let disabledGrayBackgroud = UIColor(named: "disabledGrayBackgroud")!
    static let disabledGrayText = UIColor(named: "disabledGrayText")!
    static let invalidPasswordRule = UIColor(named: "invalidPasswordRule")!}

extension UIColor {
    static var lrTealish: UIColor { UIColor(named: "lrTealish")! }
    static var lrTiffanyBlue: UIColor { UIColor(named: "lrTiffanyBlue")! }
    static var lrMango: UIColor { UIColor(named: "lrMango")! }
    static var lrApricot: UIColor { UIColor(named: "lrApricot")! }
    static var lrTealishTwo: UIColor { UIColor(named: "lrTealishTwo")! }
    static var lrTealishFour: UIColor { UIColor(named: "lrTealishFour")! }
    static var lrMintGreen: UIColor { UIColor(named: "lrMintGreen")! }
    static var lrCryonBlue: UIColor { UIColor(named: "lrCryonBlue")! }
    static var lrRedOrange: UIColor { UIColor(named: "lrRedOrange")! }
    static var lrYellowSun: UIColor { UIColor(named: "lrYellowSun")! }
    static var lrSkinTone: UIColor { UIColor(named: "lrSkinTone")! }
    static var lrLightYellow: UIColor { UIColor(named: "lrLightYellow")! }
    static var lrSLightPink: UIColor { UIColor(named: "lrSLightPink")! }
    static var lrBrownishGrey: UIColor { UIColor(named: "lrBrownishGrey")! }
    static var lrLightBrownishGrey: UIColor { UIColor(named: "lrLightBrownishGrey")! }
    static var lrPeach: UIColor { UIColor(named: "lrPeach")! }
    static var lrDarkSkyBlue: UIColor { UIColor(named: "lrDarkSkyBlue")! }
    static var lrOrange: UIColor { UIColor(named: "lrOrange")! }
    static var lrButterScotch: UIColor { UIColor(named: "lrButterScotch")! }
    static var lrFadedRed: UIColor { UIColor(named: "lrFadedRed")! }
    static var lrGreyishBrownThree: UIColor { UIColor(named: "lrGreyishBrownThree")! }
    static var lrGreyish: UIColor { UIColor(named: "lrGreyish")! }
}

// Text Font

extension UIFont {
    
    static func TurkcellSaturaDemFont(size: CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaDem", size: size)!
    }
    
    static func TurkcellSaturaRegFont(size: CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaReg", size: size)!
    }
    
    static func TurkcellSaturaBolFont(size: CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaBol", size: size)!
    }
    
    static func TurkcellSaturaItaFont(size: CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaIta", size: size)!
    }
    
    static func TurkcellSaturaMedFont(size: CGFloat = 9) -> UIFont {
        return UIFont(name: "TurkcellSaturaMed", size: size)!
    }
    
    static func TurkcellSaturaFont(size: CGFloat = 18) -> UIFont {
        return UIFont(name: "TurkcellSaturaReg", size: size)!
    }
}
