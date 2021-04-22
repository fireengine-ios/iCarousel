//
//  ColorConstants.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum ColorConstants: String, CaseIterable {
    case a2FABorder
    case backgroundViewColor
    case buttonTintColor
    case bottomBarTint
    case buttonTintBlue
    case activityTimelineDraws
    case a2FAMethodLabel
    case a2FAActiveProgress
    case alertBlueGradientEnd
    case alertBlueGradientStart
    case alertOrangeAndBlueGradientEnd
    case alertOrangeAndBlueGradientStart
    case blueGrey
    case blueColor
    case bottomViewGrayColor
    case coolGrey
    case cloudyBlue
    case confirmationPopupButton
    case darkText
    case darkBorder
    case dimmedBackground
    case duplicatesGray
    case darkBlueColor
    case fileGreedCellColor
    case greenColor
    case greenGradientEnd
    case greenGradientStart
    case grayTabBarButtonsColor
    case iconBackgroundView
    case infoPageLigherNickname
    case infoPageItemTopText
    case infoPageContactLigherBackground
    case infoPageContactDarkBackground
    case linkBlack
    case lightText
    case lightGray
    case lightGrayColor
    case loginPopupDescription
    case lrTiffanyBlueGradient
    case loginErrorLabelText
    case loginTextFieldPlaceholder
    case marineTwo
    case marineFour
    case multifileCellSubtitleText
    case multifileCellDeletionView
    case multifileCellBackgroundColor
    case multifileCellBackgroundColorSelected
    case multifileCellBackgroundColorSelectedSolid
    case navy
    case orangeGradient
    case oldieFilterColor
    case orangeGradientEnd
    case orangeGradientStart
    case photoCell
    case popUpBackground
    case profileGrayColor
    case profileLightGray
    case placeholderGrayColor
    case removeConnection
    case redGradientEnd
    case redGradientStart
    case separator
    case snackbarGray
    case searchBarColor
    case switcherGrayColor
    case switcherGreenColor
    case settingsTableBackground
    case snackBarTrashBin
    case sharedContactRoleDisabled
    case sharedContactTitleSubtitle
    case subjectPickerBackgroundColor
    case selectedBottomBarButtonColor
    case selectedCellBlueColor
    case sharedContactCircleBackground
    case textOrange
    case textDisabled
    case tableBackground
    case topBarColor
    case textGrayColor
    case textViewBackground
    case toolbarTintColor
    case textLightGrayColor
    case topBarSettingsIconColor
    case whiteColor
    case yellowColor
    case yellowButtonColor

    enum PrivateShare {
        case durationLabelUnselected
        case shareButtonBackgroundEnabled

        var color: UIColor {
            switch self {
            case .durationLabelUnselected: return UIColor(named: "durationLabel")!
            case .shareButtonBackgroundEnabled: return UIColor(named: "shareButtonBackgroundEnabled")!
            }
        }
    }

    enum Text {
        case labelTitle
        case labelTitleBackground
        case textFieldPlaceholder
        case textFieldText

        var color: UIColor {
            switch self {
            case .textFieldPlaceholder: return UIColor(named: "textFieldPlaceholder")!
            case .textFieldText: return UIColor(named: "textFieldText")!
            case .labelTitle: return UIColor(named: "labelTitle")!
            case .labelTitleBackground: return UIColor(named: "labelTitleBackground")!
            }
        }
    }

    enum UploadProgress {
        case cellBackground
        case progressBackground

        var color: UIColor {
            switch self {
            case .cellBackground: return UIColor(named: "uploadProgressCellBackground")!
            case .progressBackground: return  UIColor(named: "progressBackgroundColor")!
            }
        }
    }

    var color: UIColor {
        switch self {
        case .a2FABorder: return UIColor(named: "a2FABorderColor")!
        case .activityTimelineDraws: return UIColor(red: 6 / 255, green: 44 / 255, blue: 66 / 255, alpha: 1)
        case .a2FAMethodLabel: return UIColor(named: "a2FAMethodLabel")!
        case .a2FAActiveProgress: return UIColor(named: "a2FAActiveProgress")!
        case .alertBlueGradientEnd: return UIColor(red: 41 / 255, green: 201 / 255, blue: 236 / 255, alpha: 1.0)
        case .alertBlueGradientStart: return UIColor(red: 82 / 255, green: 120 / 255, blue:  243 / 255, alpha: 1.0)
        case .alertOrangeAndBlueGradientEnd: return UIColor(red: 67 / 255, green: 204 / 255, blue: 208 / 255, alpha: 1.0)
        case .alertOrangeAndBlueGradientStart: return UIColor(red: 255 / 255, green: 168 / 255, blue:  16 / 255, alpha: 1.0)
        case .buttonTintColor: return UIColor(red: 73/255, green: 206/255, blue: 205/255, alpha: 1)
        case .backgroundViewColor: return UIColor.black.withAlphaComponent(0.5)
        case .bottomBarTint: return UIColor(named: "bottomBarTint")!
        case .buttonTintBlue: return UIColor(named: "buttonTintBlue")!
        case .blueGrey: return UIColor(red: 139 / 255.0, green: 143 / 255.0, blue: 164 / 255.0, alpha: 1.0)
        case .blueColor: return UIColor(red: 68 / 255, green: 204 / 255, blue: 208 / 255, alpha: 1)
        case .bottomViewGrayColor: return UIColor(red: 248 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
        case .coolGrey: return UIColor(red: 179 / 255.0, green: 181 / 255.0, blue: 191 / 255.0, alpha: 1.0)
        case .cloudyBlue: return  UIColor(red: 197 / 255.0, green: 200.0 / 255.0, blue: 216 / 255.0, alpha: 1.0)
        case .confirmationPopupButton: return UIColor(named: "confirmationPopupButton")!
        case .darkText: return UIColor(red: 77 / 255, green: 77 / 255, blue: 77 / 255, alpha: 1)
        case .darkBorder: return UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)
        case .dimmedBackground: return UIColor(named: "dimmedBackground")!
        case .duplicatesGray: return UIColor(white: 86/255, alpha: 1)
        case .darkBlueColor: return UIColor(red: 5 / 255, green: 45 / 255, blue: 67 / 255, alpha: 1)
        case .fileGreedCellColor: return UIColor(red: 247 / 255, green: 247 / 255, blue: 247 / 255, alpha: 1)
        case .greenColor: return UIColor(red: 80 / 255, green: 227 / 255, blue: 119 / 255, alpha: 1)
        case .greenGradientEnd: return UIColor(red: 77 / 255, green: 218 / 255, blue: 218 / 255, alpha: 1)
        case .greenGradientStart: return UIColor(red: 92 / 255, green: 195 / 255, blue: 195 / 255, alpha: 1)
        case .grayTabBarButtonsColor: return UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1)
        case .iconBackgroundView: return UIColor(named: "iconBackgroundView")!
        case .infoPageLigherNickname: return UIColor(named: "infoPageNicknameLigher")!
        case .infoPageItemTopText: return UIColor(named: "infoPageItemTopText")!
        case .infoPageContactLigherBackground: return UIColor(named: "infoContactLigherBackground")!
        case .infoPageContactDarkBackground: return UIColor(named: "infoContactDarkBackground")!
        case .linkBlack: return UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1)
        case .lightText: return UIColor(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 1)
        case .lightGray: return UIColor(red: 104.0 / 255.0, green: 108.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)

        case .lightGrayColor: return UIColor(red: 216 / 255, green: 216 / 255, blue: 216 / 255, alpha: 1)
        case .loginPopupDescription: return UIColor(named: "loginPopupDescription")!
        case .lrTiffanyBlueGradient: return UIColor(red: 244 / 255, green: 71 / 255, blue: 87 / 255, alpha: NumericConstants.alphaForColorsPremiumButton)
        case .loginErrorLabelText: return UIColor(named: "loginErrorLabelText")!
        case .loginTextFieldPlaceholder: return UIColor(named: "loginTextFieldPlaceholder")!
        case .marineTwo: return UIColor(red: 6 / 255.0, green: 44 / 255.0, blue: 67 / 255.0, alpha: 1.0)
        case .marineFour: return UIColor(red: 6 / 255.0, green: 63 / 255.0, blue: 98 / 255.0, alpha: 1.0)
        case .multifileCellSubtitleText: return UIColor(named: "multifileCellSubtitleText")!
        case .multifileCellDeletionView: return UIColor(named: "multifileCellDeletionView")!
        case .multifileCellBackgroundColor: return UIColor(named: "multifileCellBackgroundColor")!
        case .multifileCellBackgroundColorSelected: return UIColor(named: "multifileCellBackgroundColorSelected")!
        case .multifileCellBackgroundColorSelectedSolid: return UIColor(named: "multifileCellBackgroundColorSelectedSolid")!
        case .navy: return UIColor(red: 4 / 255.0, green: 37 / 255.0, blue: 56 / 255.0, alpha: 1)
        case .orangeGradient: return UIColor(red: 255 / 255, green: 159 / 255, blue: 8 / 255, alpha: NumericConstants.alphaForColorsPremiumButton)
        case .oldieFilterColor: return UIColor(red: 1, green: 230.0 / 255.0, blue: 0, alpha: 0.4)
        case .orangeGradientEnd: return UIColor(red: 255 / 255, green: 183 / 255, blue: 116 / 255, alpha: 1)
        case .orangeGradientStart: return UIColor(red: 255 / 255, green: 177 / 255, blue: 33 / 255, alpha: 1)
        case .photoCell: return UIColor(red: 222 / 255, green: 222 / 255, blue: 222 / 255, alpha: 1)
        case .popUpBackground: return UIColor(red: 0, green: 0, blue: 0, alpha: 0.33)
        case .profileGrayColor: return UIColor(red: 234 / 255, green: 234 / 255, blue: 234 / 255, alpha: 1)
        case .profileLightGray: return UIColor(red: 186 / 255.0, green: 186 / 255.0, blue: 186 / 255.0, alpha: 1)
        case .placeholderGrayColor: return UIColor(red: 127 / 255, green: 127 / 255, blue: 127 / 255, alpha: 0.5)
        case .removeConnection: return UIColor(red: 130 / 255, green: 150 / 255, blue: 161 / 255, alpha: 1.0)

        case .redGradientEnd: return UIColor(red: 245 / 255, green: 81 / 255, blue: 95 / 255, alpha: 1)
        case .redGradientStart: return UIColor(red: 159 / 255, green: 4 / 255, blue: 27 / 255, alpha: 1)
        case .separator: return UIColor(named: "separator")!
        case .snackbarGray: return UIColor(white: 65/255, alpha: 1)
        case .searchBarColor: return UIColor(red: 3 / 255, green: 3 / 255, blue: 3 / 255, alpha: 0.09)
        case .switcherGrayColor: return UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1)
        case .switcherGreenColor: return UIColor(red: 68 / 255, green: 219 / 255, blue: 94 / 255, alpha: 1)
        case .settingsTableBackground: return UIColor(named: "settingsTableBackground")!
        case .snackBarTrashBin: return UIColor(named: "snackBarTrashBin")!
        case .sharedContactRoleDisabled: return UIColor(named: "sharedContactRoleDisabled")!
        case .sharedContactTitleSubtitle: return UIColor(named: "sharedContactTitleSubtitle")!
        case .subjectPickerBackgroundColor: return UIColor(red: 208/255, green: 211/255, blue: 216/255, alpha: 1)
        case .selectedBottomBarButtonColor: return UIColor(red: 255 / 255, green: 171 / 255, blue: 141 / 255, alpha: 1)
        case .selectedCellBlueColor: return UIColor(red: 80 / 255, green: 220 / 255, blue: 220 / 255, alpha: 0.2)
        case .sharedContactCircleBackground: return UIColor(named: "sharedContactCircleBackground")!
        case .textOrange: return UIColor(red: 255 / 255, green: 160 / 255, blue: 10 / 255, alpha: 1)
        case .textDisabled: return UIColor.black.withAlphaComponent(0.25)
        case .tableBackground: return UIColor(named: "tableBackground")!
        case .topBarColor: return UIColor(named: "topBarBackground")!
        case .textGrayColor: return UIColor(red: 95 / 255, green: 95 / 255, blue: 95 / 255, alpha: 1)
        case .textViewBackground: return UIColor(named: "textViewBackground")!
        case .toolbarTintColor: return UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        case .textLightGrayColor: return UIColor(red: 95 / 255, green: 95 / 255, blue: 95 / 255, alpha: 0.5)
        case .topBarSettingsIconColor: return UIColor(named: "topBarSettingsIconColor")!
        case .whiteColor: return UIColor.white
        case .yellowColor: return UIColor(red: 1, green: 240 / 255, blue: 149 / 255, alpha: 1)
        case .yellowButtonColor: return UIColor(red: 1, green: 199 / 255, blue: 77 / 255, alpha: 1)
        }
    }
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
