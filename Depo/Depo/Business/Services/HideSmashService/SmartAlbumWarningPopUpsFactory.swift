//
//  SmartAlbumWarningFactory.swift
//  Depo
//
//  Created by Raman Harhun on 12/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SmartAlbumWarningPopUpsFactory {

    func getPopUp(permissions: PermissionsResponse?, faceImageGrouping: SettingsInfoPermissionsResponse?, delegate: HideFuncRoutingProtocol) ->  BasePopUpController? {
        guard let permissions = permissions, let faceImageGrouping = faceImageGrouping else {
            assertionFailure("Logic issue, please check permissions and faceImageGrouping responses")
            return nil
        }

        return makePopUp(permissions: permissions, faceImageGrouping: faceImageGrouping, delegate: delegate)
    }

    private func makePopUp(permissions: PermissionsResponse, faceImageGrouping: SettingsInfoPermissionsResponse, delegate: HideFuncRoutingProtocol) -> BasePopUpController? {

        let mode: HSSmartAlbumWarningPopUp.Mode

        switch permissions {
        case let permissions where permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == false:
            mode = .faceImageGroupingDisabled

        case let permissions where !permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == true:
            mode = .notPremiumUser

        case let permissions where !permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == false:
            mode = .bothDisabled

        default:
            assertionFailure("Logic issue, please check permissions and faceImageGrouping responses")
            return nil
        }

        return HSSmartAlbumWarningPopUp(mode: mode, delegate: delegate)
    }

}
