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
        case .activityTimelineDraws: return UIColor(named: "activityTimelineDraws")!
        case .a2FAMethodLabel: return UIColor(named: "a2FAMethodLabel")!
        case .a2FAActiveProgress: return UIColor(named: "a2FAActiveProgress")!
        case .alertBlueGradientEnd: return UIColor(named: "alertBlueGradientEnd")!
        case .alertBlueGradientStart: return UIColor(named: "alertBlueGradientStart")!
        case .alertOrangeAndBlueGradientEnd: return UIColor(named: "alertOrangeAndBlueGradientEnd")!
        case .alertOrangeAndBlueGradientStart: return UIColor(named: "alertOrangeAndBlueGradientStart")!
        case .buttonTintColor: return UIColor(named: "buttonTintColor")!
        case .backgroundViewColor: return UIColor(named: "backgroundViewColor")!
        case .bottomBarTint: return UIColor(named: "bottomBarTint")!
        case .buttonTintBlue: return UIColor(named: "buttonTintBlue")!
        case .blueGrey: return UIColor(named: "blueGrey")!
        case .blueColor: return UIColor(named: "blueColor")!
        case .bottomViewGrayColor: return UIColor(named: "bottomViewGrayColor")!
        case .coolGrey: return UIColor(named: "coolGrey")!
        case .cloudyBlue: return  UIColor(named: "cloudyBlue")!
        case .confirmationPopupButton: return UIColor(named: "confirmationPopupButton")!
        case .darkText: return UIColor(named: "darkText")!
        case .darkBorder: return UIColor(named: "darkBorder")!
        case .dimmedBackground: return UIColor(named: "dimmedBackground")!
        case .duplicatesGray: return UIColor(named: "duplicatesGray")!
        case .darkBlueColor: return UIColor(named: "darkBlueColor")!
        case .fileGreedCellColor: return UIColor(named: "fileGreedCellColor")!
        case .greenColor: return UIColor(named: "greenColor")!
        case .greenGradientEnd: return UIColor(named: "greenGradientEnd")!
        case .greenGradientStart: return UIColor(named: "greenGradientStart")!
        case .grayTabBarButtonsColor: return UIColor(named: "grayTabBarButtonsColor")!
        case .iconBackgroundView: return UIColor(named: "iconBackgroundView")!
        case .infoPageLigherNickname: return UIColor(named: "infoPageNicknameLigher")!
        case .infoPageItemTopText: return UIColor(named: "infoPageItemTopText")!
        case .infoPageContactLigherBackground: return UIColor(named: "infoContactLigherBackground")!
        case .infoPageContactDarkBackground: return UIColor(named: "infoContactDarkBackground")!
        case .linkBlack: return UIColor(named: "linkBlack")!
        case .lightText: return UIColor(named: "lightText")!
        case .lightGray: return UIColor(named: "lightGray")!
        case .lightGrayColor: return UIColor(named: "lightGrayColor")!
        case .loginPopupDescription: return UIColor(named: "loginPopupDescription")!
        case .lrTiffanyBlueGradient: return UIColor(named: "lrTiffanyBlueGradient")!
        case .loginErrorLabelText: return UIColor(named: "loginErrorLabelText")!
        case .loginTextFieldPlaceholder: return UIColor(named: "loginTextFieldPlaceholder")!
        case .marineTwo: return UIColor(named: "marineTwo")!
        case .marineFour: return UIColor(named: "marineFour")!
        case .multifileCellSubtitleText: return UIColor(named: "multifileCellSubtitleText")!
        case .multifileCellDeletionView: return UIColor(named: "multifileCellDeletionView")!
        case .multifileCellBackgroundColor: return UIColor(named: "multifileCellBackgroundColor")!
        case .multifileCellBackgroundColorSelected: return UIColor(named: "multifileCellBackgroundColorSelected")!
        case .multifileCellBackgroundColorSelectedSolid: return UIColor(named: "multifileCellBackgroundColorSelectedSolid")!
        case .navy: return UIColor(named: "navy")!
        case .orangeGradient: return UIColor(named: "orangeGradient")!
        case .oldieFilterColor: return UIColor(named: "oldieFilterColor")!
        case .orangeGradientEnd: return UIColor(named: "orangeGradientEnd")!
        case .orangeGradientStart: return UIColor(named: "orangeGradientStart")!
        case .photoCell: return UIColor(named: "photoCell")!
        case .popUpBackground: return UIColor(named: "popUpBackground")!
        case .profileGrayColor: return UIColor(named: "profileGrayColor")!
        case .profileLightGray: return UIColor(named: "profileLightGray")!
        case .placeholderGrayColor: return UIColor(named: "placeholderGrayColor")!
        case .removeConnection: return UIColor(named: "removeConnection")!
        case .redGradientEnd: return UIColor(named: "redGradientEnd")!
        case .redGradientStart: return UIColor(named: "redGradientStart")!
        case .separator: return UIColor(named: "separator")!
        case .snackbarGray: return UIColor(named: "snackbarGray")!
        case .searchBarColor: return UIColor(named: "searchBarColor")!
        case .switcherGrayColor: return UIColor(named: "switcherGrayColor")!
        case .switcherGreenColor: return UIColor(named: "switcherGreenColor")!
        case .settingsTableBackground: return UIColor(named: "settingsTableBackground")!
        case .snackBarTrashBin: return UIColor(named: "snackBarTrashBin")!
        case .sharedContactRoleDisabled: return UIColor(named: "sharedContactRoleDisabled")!
        case .sharedContactTitleSubtitle: return UIColor(named: "sharedContactTitleSubtitle")!
        case .subjectPickerBackgroundColor: return UIColor(named: "subjectPickerBackgroundColor")!
        case .selectedBottomBarButtonColor: return UIColor(named: "selectedBottomBarButtonColor")!
        case .selectedCellBlueColor: return UIColor(named: "selectedCellBlueColor")!
        case .sharedContactCircleBackground: return UIColor(named: "sharedContactCircleBackground")!
        case .textOrange: return UIColor(named: "textOrange")!
        case .textDisabled: return UIColor(named: "textDisabled")!
        case .tableBackground: return UIColor(named: "tableBackground")!
        case .topBarColor: return UIColor(named: "topBarBackground")!
        case .textGrayColor: return UIColor(named: "textGrayColor")!
        case .textViewBackground: return UIColor(named: "textViewBackground")!
        case .toolbarTintColor: return UIColor(named: "toolbarTintColor")!
        case .textLightGrayColor: return UIColor(named: "textLightGrayColor")!
        case .topBarSettingsIconColor: return UIColor(named: "topBarSettingsIconColor")!
        case .whiteColor: return UIColor(named: "whiteColor")!
        case .yellowColor: return UIColor(named: "yellowColor")!
        case .yellowButtonColor: return UIColor(named: "yellowButtonColor")!
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
