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
    case tabBarTint
    case tabBarTintSelected
    case tabBarCardBackground
    case tabBarCardBackgroundAlternative
    case tabBarCardShadow
    case tabBarCardLabel
    case tabBarCardProgressTint
    case tabBarCardProgressTrack

    // MARK: General
    case background
    case secondaryBackground
    case label
    case darkLabel
    case tint
    case separator
    case lightText

    case loginShadowBlue
    case darkContentOverlay
    case lightContentOverlay
    
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
    
    // MARK: Switch
    case SwitchBackgroundColor
    
    // MARK: Face Image
    case mapCountBackground
    
    // MARK: For You
    case forYouButton
    case forYouFaceImageBackground
    
    // MARK: Settings
    case borderColor
    case profileInfoOrange
    case arrowDownOpenColor
    case profileTintColor
    case settingsBottomInfo

    
    //MARK: Landing
    case landingGradientFinish
    case landingGradientStart
    case appleGoogleLoginLabel

    // MARK: Login
    case loginAlertView

    
    //TODO: Facelift: Uncomment below
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ - FACELIFT - ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    
    
    
    // MARK: Legacy
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
    

    var color: UIColor {
        guard let uiColor = UIColor(named: String(describing: self)) else {
            assertionFailure()
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
