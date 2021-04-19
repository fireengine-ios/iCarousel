//
//  ColorConstants.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

struct ColorConstants {
    //MARK: Business App specific
    
    static let bottomBarTint = UIColor(named: "bottomBarTint")!
    static let buttonTintBlue = UIColor(named: "buttonTintBlue")!
    static let multifileCellSubtitleText = UIColor(named: "multifileCellSubtitleText")!
    static let multifileCellBackgroundColor = UIColor(named: "multifileCellBackgroundColor")!
    static let multifileCellBackgroundColorSelected = UIColor(named: "multifileCellBackgroundColorSelected")!
    static let multifileCellBackgroundColorSelectedSolid = UIColor(named: "multifileCellBackgroundColorSelectedSolid")!
    static let multifileCellDeletionView = UIColor(named: "multifileCellDeletionView")!

    static let confirmationPopupButton = UIColor(named: "confirmationPopupButton")!
    
    static let loginErrorLabelText = UIColor(named: "loginErrorLabelText")!
    static let loginTextFieldPlaceholder = UIColor(named: "loginTextFieldPlaceholder")!

    static let loginPopupDescription = UIColor(named: "loginPopupDescription")!
    
    static let textViewBackground = UIColor(named: "textViewBackground")!
    
    static let separator = UIColor(named: "separator")!
    
    struct PrivateShare {
        static let shareButtonBackgroundEnabled = UIColor(named: "shareButtonBackgroundEnabled")!
        static let durationLabelUnselected = UIColor(named: "durationLabel")!
    }
    
    struct Text {
        static let textFieldPlaceholder = UIColor(named: "textFieldPlaceholder")!
        static let textFieldText = UIColor(named: "textFieldText")!
        static let labelTitle = UIColor(named: "labelTitle")!
        static let labelTitleBackground = UIColor(named: "labelTitleBackground")!
    }
    
    struct UploadProgress {
        static let cellBackground = UIColor(named: "uploadProgressCellBackground")!
        static let progressBackground = UIColor(named: "progressBackgroundColor")!
    }

    static let infoPageItemTopText = UIColor(named: "infoPageItemTopText")!
    static let infoPageContactDarkBackground = UIColor(named: "infoContactDarkBackground")!
    static let infoPageContactLigherBackground = UIColor(named: "infoContactLigherBackground")!
    static let infoPageLigherNickname = UIColor(named: "infoPageNicknameLigher")!
    static let sharedContactTitleSubtitle = UIColor(named: "sharedContactTitleSubtitle")!
    static let sharedContactCircleBackground = UIColor(named: "sharedContactCircleBackground")!
    static let sharedContactRoleDisabled = UIColor(named: "sharedContactRoleDisabled")!
    static let a2FAMethodLabel = UIColor(named: "a2FAMethodLabel")!
    static let tableBackground = UIColor(named: "tableBackground")!
    static let dimmedBackground = UIColor(named: "dimmedBackground")!
    static let a2FABorder = UIColor(named: "a2FABorderColor")!
    static let a2FAActiveProgress = UIColor(named: "a2FAActiveProgress")!
    static let iconBackgroundView = UIColor(named: "iconBackgroundView")!
    static let settingsTableBackground = UIColor(named: "settingsTableBackground")!
    static let snackBarTrashBin = UIColor(named: "snackBarTrashBin")!

    static let topBarColor = UIColor(named: "topBarBackground")!
    static let topBarSettingsIconColor = UIColor(named: "topBarSettingsIconColor")!
    
    //MARK: END
    
    static let whiteColor = UIColor.white
    static let blueColor = UIColor(red: 68 / 255, green: 204 / 255, blue: 208 / 255, alpha: 1)
    static let yellowColor = UIColor(red: 1, green: 240 / 255, blue: 149 / 255, alpha: 1)
    static let switcherGrayColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1)
    static let switcherGreenColor = UIColor(red: 68 / 255, green: 219 / 255, blue: 94 / 255, alpha: 1)
    static let textGrayColor = UIColor(red: 95 / 255, green: 95 / 255, blue: 95 / 255, alpha: 1)
    static let textLightGrayColor = UIColor(red: 95 / 255, green: 95 / 255, blue: 95 / 255, alpha: 0.5)
    static let greenColor = UIColor(red: 80 / 255, green: 227 / 255, blue: 119 / 255, alpha: 1)
    static let lightGrayColor = UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
    static let profileGrayColor = UIColor(red: 234 / 255, green: 234 / 255, blue: 234 / 255, alpha: 1)
    static let selectedCellBlueColor = UIColor(red: 80 / 255, green: 220 / 255, blue: 220 / 255, alpha: 0.2)
    static let selectedBottomBarButtonColor = UIColor(red: 255 / 255, green: 171 / 255, blue: 141 / 255, alpha: 1)
    static let fileGreedCellColor = UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1)
    static let darkBlueColor = UIColor(red: 5 / 255, green: 45 / 255, blue: 67 / 255, alpha: 1)
    static let searchBarColor = UIColor(red: 3 / 255, green: 3 / 255, blue: 3 / 255, alpha: 0.09)
    static let darkText = UIColor(red: 77 / 255, green: 77 / 255, blue: 77 / 255, alpha: 1)
    static let lightText = UIColor(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 1)
    static let placeholderGrayColor = UIColor(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 0.5)
    static let activityTimelineDraws = UIColor(red: 6 / 255, green: 44 / 255, blue: 66 / 255, alpha: 1)
    static let yellowButtonColor = UIColor(red: 1, green: 199 / 255, blue: 77 / 255, alpha: 1)
    static let grayTabBarButtonsColor = UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1)
    static let textOrange = UIColor(red: 255 / 255, green: 160 / 255, blue: 10 / 255, alpha: 1)
    static let darkBorder = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)
    static let oldieFilterColor = UIColor(red: 1, green: 230.0 / 255.0, blue: 0, alpha: 0.4)
    static let bottomViewGrayColor = UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
    static let lightGray = UIColor(red: 104.0 / 255.0, green: 108.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
    
    static let orangeGradientStart = UIColor(red: 255 / 255, green: 177 / 255, blue: 33 / 255, alpha: 1)
    static let orangeGradientEnd = UIColor(red: 255 / 255, green: 183 / 255, blue: 116 / 255, alpha: 1)
    static let greenGradientStart = UIColor(red: 92 / 255, green: 195 / 255, blue: 195 / 255, alpha: 1)
    static let greenGradientEnd = UIColor(red: 77 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1)
    static let redGradientStart = UIColor(red: 159 / 255, green: 4 / 255, blue: 27 / 255, alpha: 1)
    static let redGradientEnd = UIColor(red: 245 / 255, green: 81 / 255, blue: 95 / 255, alpha: 1)
    static let photoCell = UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
    
    static let lrTiffanyBlueGradient = UIColor(red: 244 / 255, green: 71 / 255, blue: 87 / 255, alpha: NumericConstants.alphaForColorsPremiumButton)
    static let orangeGradient = UIColor(red: 255 / 255, green: 159 / 255, blue: 8 / 255, alpha: NumericConstants.alphaForColorsPremiumButton)
    static let removeConnection = UIColor(red: 130 / 255, green: 150 / 255, blue: 161 / 255, alpha: 1.0)
    
    static let alertBlueGradientStart = UIColor(red: 82 / 255, green: 120 / 255, blue:  243 / 255, alpha: 1.0)
    static let alertBlueGradientEnd = UIColor(red: 41 / 255, green: 201 / 255, blue: 236 / 255, alpha: 1.0)
    
    static let alertOrangeAndBlueGradientStart = UIColor(red: 255 / 255, green: 168 / 255, blue:  16 / 255, alpha: 1.0)
    static let alertOrangeAndBlueGradientEnd = UIColor(red: 67 / 255, green: 204 / 255, blue: 208 / 255, alpha: 1.0)
    
    static let subjectPickerBackgroundColor = UIColor(red: 208/255, green: 211/255, blue: 216/255, alpha: 1)
    static let toolbarTintColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    static let buttonTintColor = UIColor(red: 73/255, green: 206/255, blue: 205/255, alpha: 1)
    
    static let cloudyBlue = UIColor(red: 197 / 255.0, green: 200.0 / 255.0, blue: 216 / 255.0, alpha: 1.0)
    static let blueGrey = UIColor(red: 139 / 255.0, green: 143 / 255.0, blue: 164 / 255.0, alpha: 1.0)
    static let coolGrey = UIColor(red: 179 / 255.0, green: 181 / 255.0, blue: 191 / 255.0, alpha: 1.0)
    static let textDisabled = UIColor.black.withAlphaComponent(0.25)
    
    static let marineTwo = UIColor(red: 6 / 255.0, green: 44 / 255.0, blue: 67 / 255.0, alpha: 1.0)
    static let marineFour = UIColor(red: 6 / 255.0, green: 63 / 255.0, blue: 98 / 255.0, alpha: 1.0)
    
    static let popUpBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.33)
    
    static let backgroundViewColor = UIColor.black.withAlphaComponent(0.5)

    static let profileLightGray = UIColor(red: 186 / 255.0, green: 186 / 255.0, blue: 186 / 255.0, alpha: 1)

    static let linkBlack = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1)
    
    static let snackbarGray = UIColor(white: 65/255, alpha: 1)
    
    static let duplicatesGray = UIColor(white: 86/255, alpha: 1)

    static let navy = UIColor(red: 4 / 255.0, green: 37 / 255.0, blue: 56 / 255.0, alpha: 1)
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
    
    class var lrTealishFour: UIColor {
        return UIColor(red: 64.0 / 255.0, green: 204.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
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
    
    class var lrLightYellow: UIColor {
        return UIColor(red: 254.0 / 255.0, green: 233.0 / 255.0, blue: 188.0 / 255.0, alpha: 1.0)
    }
    
    class var lrSLightPink: UIColor {
        return UIColor(red: 248.0 / 255.0, green: 194.0 / 255.0, blue: 190.0 / 255.0, alpha: 1.0)
    }
    
    class var lrBrownishGrey: UIColor {
        return UIColor(red: 95 / 255.0, green: 95 / 255.0, blue: 95 / 255.0, alpha: 1.0)
    }
    
    class var lrLightBrownishGrey: UIColor {
        return UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1.0)
    }
    
    class var lrPeach: UIColor {
        return UIColor(red: 254.0 / 255.0, green: 171.0 / 255.0, blue: 143.0 / 255.0, alpha: 1.0)
    }
    
    class var lrDarkSkyBlue: UIColor {
        return UIColor(red: 65 / 255.0, green: 180 / 255.0, blue: 224 / 255.0, alpha: 1.0)
    }
    
    class var lrOrange: UIColor {
        return UIColor(red: 245 / 255.0, green: 115 / 255.0, blue: 14 / 255.0, alpha: 1.0)
    }
    
    class var lrButterScotch: UIColor {
        return UIColor(red: 255 / 255.0, green: 198 / 255.0, blue: 75 / 255.0, alpha: 1.0)
    }
    
    class var lrFadedRed: UIColor {
        return UIColor(red: 217 / 255.0, green: 58 / 255.0, blue: 71 / 255.0, alpha: 1.0)
    }
    
    class var lrGreyishBrownThree: UIColor {
        return UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1.0)
    }

    class var lrGreyish: UIColor {
        return UIColor(red: 178 / 255.0, green: 178 / 255.0, blue: 178 / 255.0, alpha: 1.0)
    }
}
