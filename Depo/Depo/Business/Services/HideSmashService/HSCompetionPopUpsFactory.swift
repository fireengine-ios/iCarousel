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
        case hideAlbumsCompleted
        case smashCompleted
        case hideSimpleCompleted
    }

    private var storageVars: StorageVars = factory.resolve()

    func getPopUp(for state: State, itemsCount: Int, delegate: HideFuncRoutingProtocol) ->  UIViewController {
        return makePopUp(for: state, itemsCount: itemsCount, delegate: delegate)
    }

    private func makePopUp(for state: State, itemsCount: Int, delegate: HideFuncRoutingProtocol) -> UIViewController {
        switch state {
        case .hideCompleted:
            if isDoNotShowAgainButtonPressed(for: state) {
                return HSCompletionPopUp(mode: .showBottomCloseButton, photosCount: itemsCount, delegate: delegate)
            } else {
                return HSCompletionPopUp(mode: .showOpenSmartAlbumButton, photosCount: itemsCount, delegate: delegate)
            }
            
        case .hideAlbumsCompleted:
            return HSCompletionPopUp(mode: .hiddenAlbums, photosCount: itemsCount, delegate: delegate)
            
        case .smashCompleted:
            if isDoNotShowAgainButtonPressed(for: state) {
                return PopUpController.with(title: TextConstants.smashSuccessedSimpleAlertTitle,
                                            message: TextConstants.smashSuccessedSimpleAlertDescription,
                                            image: .success,
                                            buttonTitle: TextConstants.ok)
                
            } else {
                return HSCompletionPopUp(mode: .smash, photosCount: itemsCount, delegate: delegate)
            }
            
        case .hideSimpleCompleted:
            return HSCompletionPopUp(mode: .hiddenPhotosOnly, photosCount: itemsCount, delegate: delegate)
        }
    }

    private func isDoNotShowAgainButtonPressed(for state: State) -> Bool {
        let isDoNotShowAgainButtonPressed: Bool
        
        switch state {
        case .hideCompleted:
            isDoNotShowAgainButtonPressed = storageVars.hiddenPhotoInPeopleAlbumPopUpCheckBox
            
        case .smashCompleted:
            isDoNotShowAgainButtonPressed = storageVars.smashPhotoPopUpCheckBox
            
        case .hideSimpleCompleted, .hideAlbumsCompleted:
            assertionFailure("there is no button for this type of popup")
            return false
        }

        return isDoNotShowAgainButtonPressed
    }
}
