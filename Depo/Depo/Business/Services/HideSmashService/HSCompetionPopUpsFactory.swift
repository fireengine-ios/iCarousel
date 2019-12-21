//
//  HidePopUpsFactory.swift
//  Depo
//
//  Created by Raman Harhun on 12/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

//HS - Hide and Smash
final class HSCompletionPopUpsFactory {

    enum State {
        case hideCompleted
        case smashCompleted
    }

    private var storageVars: StorageVars = factory.resolve()

    func getPopUp(for state: State, itemsCount: Int, delegate: HideFuncRoutingProtocol) ->  UIViewController {
        return makePopUp(for: state, itemsCount: itemsCount, delegate: delegate)
    }

    private func makePopUp(for state: State, itemsCount: Int, delegate: HideFuncRoutingProtocol) -> UIViewController {
        switch state {
        case .hideCompleted where isDoNotShowAgainButtonPressed(for: state):
            return HSCompletionPopUp(mode: .showBottomCloseButton, photosCount: itemsCount, delegate: delegate)

        case .hideCompleted where !isDoNotShowAgainButtonPressed(for: state):
            return HSCompletionPopUp(mode: .showOpenSmartAlbumButton, photosCount: itemsCount, delegate: delegate)

        case .smashCompleted where isDoNotShowAgainButtonPressed(for: state):
            return PopUpController.with(title: TextConstants.smashSuccessedSimpleAlertTitle,
                                        message: TextConstants.smashSuccessedSimpleAlertDescription,
                                        image: .success,
                                        buttonTitle: TextConstants.ok)

        case .smashCompleted where !isDoNotShowAgainButtonPressed(for: state):
            return HSCompletionPopUp(mode: .smash, photosCount: itemsCount, delegate: delegate)

        default:
            assertionFailure("Attack on a matrix")
            return PopUpController.with(errorMessage: TextConstants.errorUnknown)
        }
    }

    private func isDoNotShowAgainButtonPressed(for state: State) -> Bool {
        let isDoNotShowAgainButtonPressed: Bool

        switch state {
            case .hideCompleted:
                isDoNotShowAgainButtonPressed = storageVars.hiddenPhotoInPeopleAlbumPopUpCheckBox

            case .smashCompleted:
                isDoNotShowAgainButtonPressed = storageVars.smashPhotoPopUpCheckBox

        }

        return isDoNotShowAgainButtonPressed
    }
}
