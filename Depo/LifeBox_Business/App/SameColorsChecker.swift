//
//  SameColorsChecker.swift
//  Depo
//
//  Created by Anton Ignatovich on 19.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class SameColorsChecker {
    let allColors: [String: CGColor] = [
        "a2FABorder" : ColorConstants.a2FABorder.cgColor,
        "activityTimelineDraws" : ColorConstants.activityTimelineDraws.cgColor,
        "a2FAMethodLabel" : ColorConstants.a2FAMethodLabel.cgColor,
        "a2FAActiveProgress" : ColorConstants.a2FAActiveProgress.cgColor,
        "alertBlueGradientEnd" : ColorConstants.alertBlueGradientEnd.cgColor,
        "alertBlueGradientStart" : ColorConstants.alertBlueGradientStart.cgColor,
        "alertOrangeAndBlueGradientEnd" : ColorConstants.alertOrangeAndBlueGradientEnd.cgColor,
        "alertOrangeAndBlueGradientStart" : ColorConstants.alertOrangeAndBlueGradientStart.cgColor,
        "blueGrey" : ColorConstants.blueGrey.cgColor,
        "blueColor" : ColorConstants.blueColor.cgColor,
        "bottomBarTint" : ColorConstants.bottomBarTint.cgColor,
        "buttonTintBlue" : ColorConstants.buttonTintBlue.cgColor,
        "buttonTintColor" : ColorConstants.buttonTintColor.cgColor,
        "backgroundViewColor" : ColorConstants.backgroundViewColor.cgColor,
        "bottomViewGrayColor" : ColorConstants.bottomViewGrayColor.cgColor,
        "coolGrey" : ColorConstants.coolGrey.cgColor,
        "cloudyBlue" : ColorConstants.cloudyBlue.cgColor,
        "confirmationPopupButton" : ColorConstants.confirmationPopupButton.cgColor,
        "darkText" : ColorConstants.darkText.cgColor,
        "darkBorder" : ColorConstants.darkBorder.cgColor,
        "dimmedBackground" : ColorConstants.dimmedBackground.cgColor,
        "duplicatesGray" : ColorConstants.duplicatesGray.cgColor,
        "darkBlueColor" : ColorConstants.darkBlueColor.cgColor,
        "fileGreedCellColor" : ColorConstants.fileGreedCellColor.cgColor,
        "greenColor" : ColorConstants.greenColor.cgColor,
        "greenGradientEnd" : ColorConstants.greenGradientEnd.cgColor,
        "greenGradientStart" : ColorConstants.greenGradientStart.cgColor,
        "grayTabBarButtonsColor" : ColorConstants.grayTabBarButtonsColor.cgColor,
        "iconBackgroundView" : ColorConstants.iconBackgroundView.cgColor,
        "infoPageLigherNickname" : ColorConstants.infoPageLigherNickname.cgColor,
        "infoPageItemTopText" : ColorConstants.infoPageItemTopText.cgColor,
        "infoPageContactLigherBackground" : ColorConstants.infoPageContactLigherBackground.cgColor,
        "infoPageContactDarkBackground" : ColorConstants.infoPageContactDarkBackground.cgColor,
        "linkBlack" : ColorConstants.linkBlack.cgColor,
        "lightText" : ColorConstants.lightText.cgColor,
        "lightGray" : ColorConstants.lightGray.cgColor,
        "lightGrayColor" : ColorConstants.lightGrayColor.cgColor,
        "loginPopupDescription" : ColorConstants.loginPopupDescription.cgColor,
        "lrTiffanyBlueGradient" : ColorConstants.lrTiffanyBlueGradient.cgColor,
        "loginErrorLabelText" : ColorConstants.loginErrorLabelText.cgColor,
        "loginTextFieldPlaceholder" : ColorConstants.loginTextFieldPlaceholder.cgColor,
        "marineTwo" : ColorConstants.marineTwo.cgColor,
        "marineFour" : ColorConstants.marineFour.cgColor,
        "multifileCellSubtitleText" : ColorConstants.multifileCellSubtitleText.cgColor,
        "multifileCellDeletionView" : ColorConstants.multifileCellDeletionView.cgColor,
        "multifileCellBackgroundColor" : ColorConstants.multifileCellBackgroundColor.cgColor,
        "multifileCellBackgroundColorSelected" : ColorConstants.multifileCellBackgroundColorSelected.cgColor,
        "multifileCellBackgroundColorSelectedSolid" : ColorConstants.multifileCellBackgroundColorSelectedSolid.cgColor,
        "navy" : ColorConstants.navy.cgColor,
        "orangeGradient" : ColorConstants.orangeGradient.cgColor,
        "oldieFilterColor" : ColorConstants.oldieFilterColor.cgColor,
        "orangeGradientEnd" : ColorConstants.orangeGradientEnd.cgColor,
        "orangeGradientStart" : ColorConstants.orangeGradientStart.cgColor,
        "photoCell" : ColorConstants.photoCell.cgColor,
        "popUpBackground" : ColorConstants.popUpBackground.cgColor,
        "profileGrayColor" : ColorConstants.profileGrayColor.cgColor,
        "profileLightGray" : ColorConstants.profileLightGray.cgColor,
        "placeholderGrayColor" : ColorConstants.placeholderGrayColor.cgColor,
        "removeConnection" : ColorConstants.removeConnection.cgColor,
        "redGradientEnd" : ColorConstants.redGradientEnd.cgColor,
        "redGradientStart" : ColorConstants.redGradientStart.cgColor,
        "separator" : ColorConstants.separator.cgColor,
        "snackbarGray" : ColorConstants.snackbarGray.cgColor,
        "searchBarColor" : ColorConstants.searchBarColor.cgColor,
        "switcherGrayColor" : ColorConstants.switcherGrayColor.cgColor,
        "switcherGreenColor" : ColorConstants.switcherGreenColor.cgColor,
        "settingsTableBackground" : ColorConstants.settingsTableBackground.cgColor,
        "snackBarTrashBin" : ColorConstants.snackBarTrashBin.cgColor,
        "sharedContactRoleDisabled" : ColorConstants.sharedContactRoleDisabled.cgColor,
        "sharedContactTitleSubtitle" : ColorConstants.sharedContactTitleSubtitle.cgColor,
        "subjectPickerBackgroundColor" : ColorConstants.subjectPickerBackgroundColor.cgColor,
        "selectedBottomBarButtonColor" : ColorConstants.selectedBottomBarButtonColor.cgColor,
        "selectedCellBlueColor" : ColorConstants.selectedCellBlueColor.cgColor,
        "sharedContactCircleBackground" : ColorConstants.sharedContactCircleBackground.cgColor,
        "textOrange" : ColorConstants.textOrange.cgColor,
        "textDisabled" : ColorConstants.textDisabled.cgColor,
        "tableBackground" : ColorConstants.tableBackground.cgColor,
        "topBarColor" : ColorConstants.topBarColor.cgColor,
        "textGrayColor" : ColorConstants.textGrayColor.cgColor,
        "textViewBackground" : ColorConstants.textViewBackground.cgColor,
        "toolbarTintColor" : ColorConstants.toolbarTintColor.cgColor,
        "textLightGrayColor" : ColorConstants.textLightGrayColor.cgColor,
        "topBarSettingsIconColor" : ColorConstants.topBarSettingsIconColor.cgColor,
        "whiteColor" : ColorConstants.whiteColor.cgColor,
        "yellowColor" : ColorConstants.yellowColor.cgColor,
        "yellowButtonColor" : ColorConstants.yellowButtonColor.cgColor,
        "PrivateShare.durationLabelUnselected": ColorConstants.PrivateShare.durationLabelUnselected.cgColor,
        "PrivateShare.shareButtonBackgroundEnabled": ColorConstants.PrivateShare.shareButtonBackgroundEnabled.cgColor,
        "Text.labelTitle": ColorConstants.Text.labelTitle.cgColor,
        "Text.labelTitleBackground": ColorConstants.Text.labelTitleBackground.cgColor,
        "Text.textFieldPlaceholder": ColorConstants.Text.textFieldPlaceholder.cgColor,
        "Text.textFieldText": ColorConstants.Text.textFieldText.cgColor,
        "UploadProgress.cellBackground": ColorConstants.UploadProgress.cellBackground.cgColor,
        "UploadProgress.progressBackground": ColorConstants.UploadProgress.progressBackground.cgColor
    ]

    func checkColorDuplicates() -> [String: [String]] {
        var duplicates: [String: [String]] = [:]
        for colorPair in allColors {
            duplicates[colorPair.key] = checkDuplicatesForColorWithNameInConstants(with: colorPair.key)
        }
        return duplicates.filter { !$0.value.isEmpty }
    }

    func checkDuplicatesForColorWithNameInConstants(with name: String) -> [String] {
        guard let desiredCGColor = allColors[name] else { return [] }

        var duplicates: [String] = []

        for colorPairInner in allColors {
            if colorPairInner.key.elementsEqual(name) { continue }
            if desiredCGColor == colorPairInner.value {
                duplicates.append(colorPairInner.key)
            }
        }

        return duplicates
    }

    func searchForColors(with cgColor: CGColor) -> [String] {
        var duplicates: [String] = []

        for colorPairInner in allColors {
            if cgColor == colorPairInner.value {
                duplicates.append(colorPairInner.key)
            }
        }

        return duplicates
    }
}
