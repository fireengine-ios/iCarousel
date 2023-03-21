//
//  AppColor.swift
//  Depo
//
//  Created by Burak Donat on 23.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum AppColor {

    // MARK: NavigationBar
    case navigationBarBackground
    case navigationBarTitle
    case navigationBarIcons
    case navigationBarBackgroundBlack
    case navigationBarTitleBlack
    case navigationBarIconsBlack

    // MARK: TabBar
    case tabBarCardBackground
    case tabBarCardBackgroundAlternative
    case tabBarCardShadow
    case tabBarCardLabel
    case tabBarCardProgressTint
    case tabBarCardProgressTrack

    // MARK: General
    case warning
    case readState
    case background
    case secondaryBackground
    case tertiaryBackground
    case label
    case labelSingle
    case darkLabel
    case tint
    case darkTint
    case separator
    case lightText
    case button
    case secondaryButton
    case darkBackground
    case secondaryTint
    case purchaseButton
    case notification

    case loginShadowBlue
    case darkContentOverlay
    case lightContentOverlay
    
    case tabBarUnselect
    case tabBarSelect
    case tabBarUnselectOnly
    
    case tableViewSection
    case cellBackground
    
    case snackbarBackground
    
    // MARK: PhotoVideoDetail
    case functionsMenuTint
    case recognizeBackground
    case PVDetailTabBarSelect
    case PVDetailTabBarUnSelect
    
    // MARK: FilesTab
    case filesBackground
    case filesBigCellBackground
    case filesLabel
    case filesBigCellShadow
    case filesBigImageBackground
    case filesRefresher
    
    case filesTypesBackground
    case filesMusicTab
    case filesDocumentTab
    case filesFavoriteTab
    case filesSharedTab
    case filesSeperator
    case filesSharedTabSeperator
    case filesSharedInfoBackground
    case filesShareDurationBackground

    // MARK: Drawer
    case drawerShadow
    case drawerIndicator
    case drawerBackground
    case drawerButtonBorder

    // MARK: PopUp
    case popUpTitle
    case popUpMessage
    case popUpTitleError
    case popUpButtonNormal
    case popUpButtonCancel
    case popupTint
    case darkRedBottomPopup
    
    // MARK: Switch
    case SwitchBackgroundColor
    
    // MARK: Face Image
    case mapCountBackground
    
    // MARK: For You
    case forYouButton
    case forYouFaceImageBackground
    case tbtBlurBackground
    case tbtButton
    case collageThumbnailColor
    case collageBorderColor
    case collageCellBorder
    
    // MARK: Contact
    case grayMain
    case darkBlue
    case darkBlueColor
    case contactHeader
    case contactHeaderText
    case progressFront
    
    // MARK: Settings
    case borderColor
    case profileInfoOrange
    case arrowDownOpenColor
    case profileTintColor
    case settingsBottomInfo
    case settingsMyPackages
    case settingsPackages
    case settingsRestoreTextColor
    case settingsPackagesCell
    case SettingsPackagesRecommendedOne
    case SettingsPackagesRecommendedTwo
    case SettingsPackagesRecommendedThree
    case SettingsPackagesRecommendedFour
    case settingsPremiumListShadow
    case settingsBackground
    case passcodeTint
    case settingsButtonNormal
    case campaignBackground
    case campaignDarkLabel
    case campaignLightLabel
    case campaignBorder
    case campaignContentLabel
    case syncHeader
    
    //ConnectedAccounts
    case toggleOn
    
    //MARK: Landing
    case landingGradientFinish
    case landingGradientStart
    case appleGoogleLoginLabel

    // MARK: Login
    case loginAlertView
        
    // MARK: Forget MY Password
    case forgetPassText
    case forgetPassButtonDisable
    case forgetPassButtonNormal
    case forgetPassCodeClose
    case forgetPassCodeOpen
    case forgetPassTimer
    case forgetPassTextGreen
    case forgetPassTextRed
    case forgetBorder
    
    // MARK: Register
    case registerPrivacyPolicy
    case registerNextButtonNormal
    case registerNextButtonNormalTextColor
    case registerLabelTextColor
    
    // MARK: Gradient
    case premiumFirstGradient
    case premiumSecondGradient
    case premiumThirdGradient
    case premiumGradientLabel
    case InstaPickGradientOne
    
    // MARK: Landing
    case landingSubtitle
    case landingTitle
    case landingButton
    case landingPageIndicator

    //TODO: Facelift: Uncomment below
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ - FACELIFT - ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    
    
    
    // MARK: Legacy
    case lightGrayColor
    case primaryBackground
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
    case blackAndWhite
    case viewShadowLight
    case borderLightGray
    case tbMatikBlurColor
    case discoverCardLine
    case settingsButtonColor
    

    var color: UIColor {
        guard let uiColor = UIColor(named: String(describing: self)) else {
            assertionFailure("Color not found with name: \(self)")
            return UIColor()
        }

        return uiColor
    }

    var cgColor: CGColor {
        return color.cgColor
    }

    func withAlphaComponent(_ alpha: CGFloat) -> UIColor {
        return color.withAlphaComponent(alpha)
    }
}

func color(_ color: AppColor) -> UIColor {
    return color.color
}
