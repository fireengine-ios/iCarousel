//
//  HideFunctionalityService.swift
//  Depo
//
//  Created by Raman Harhun on 12/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

protocol HideFuncRoutingProtocol: class {
    //HideFuncPeopleAlbumWarningPopUp
    func openPremium()
    func openFaceImageGrouping()

    //HideFuncCompletionPopUp
    func openHiddenAlbum()
    func openPeopleAlbumIfPossible()
}

protocol HideFuncServiceProtocol {
    func startHideOperation(for items: [Item], success: @escaping FileOperation, fail: @escaping FailResponse)
}

final class HideFunctionalityService: HideFuncServiceProtocol {

    //MARK: Properties

    private var items: [Item] = []
    
    private var success: FileOperation?
    private var fail: FailResponse?
    
    private var permissions: PermissionsResponse?
    private var faceImageGrouping: SettingsInfoPermissionsResponse?
    
    private lazy var fileService = WrapItemFileService()
    private lazy var player: MediaPlayer = factory.resolve()
    
    private let router = RouterVC()
    
    private var peopleAlbumRequestsGroup: DispatchGroup?

    //MARK: PopUp

    private var confirmationPopUp: UIViewController {
        let message = items.count > 1 ? TextConstants.hideItemsWarningMessage : TextConstants.hideSinglePhotoCompletionAlertMessage
        return PopUpController.with(title: TextConstants.hideItemsWarningTitle,
                                    message: message,
                                    image: .hide,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    secondAction: { [weak self] popUp in
                                        popUp.close {
                                            self?.hidePhotos()
                                        }
        })
    }

    //MARK: Service

    private lazy var accountService: AccountServicePrl = AccountService()

    //MARK: Utility Methods (Public)

    func startHideOperation(for items: [Item], success: @escaping FileOperation, fail: @escaping FailResponse) {
        self.items = items
        self.success = success
        self.fail = fail
        
        showConfirmationPopUp()
    }

    //MARK: Utility Methods (Private)

    private func showConfirmationPopUp() {
        router.presentViewController(controller: confirmationPopUp)
    }

    private func hiddenSuccessfully() {
        success?()
        
        showSuccessPopUp()
    }

    private func showSuccessPopUp() {
        let controller = HideFuncCompletionPopUp(photosCount: items.count, delegate: self)
        router.presentViewController(controller: controller, animated: false)
    }

    private func preparePeopleAlbumOpenning() {
        let group = DispatchGroup()

        group.enter()
        group.enter()

        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.peopleAlbumRequestsGroup = nil

            self?.didObtainPeopleAlbumInfo()
        }

        peopleAlbumRequestsGroup = group

        getPermissions()
        getFaceImageGroupingStatus()
    }
    
    private func didObtainPeopleAlbumInfo() {
        guard let permissions = permissions, let faceImageGrouping = faceImageGrouping else {
            return
        }

        switch permissions {
        case let permissions where permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == true:
            openPeopleAlbum()

        case let permissions where permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == false:
            openPeopleAlbumWarningPopUp(mode: .faceImageGroupingDisabled)

        case let permissions where !permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == true:
            openPeopleAlbumWarningPopUp(mode: .notPremiumUser)

        case let permissions where !permissions.hasPermissionFor(.faceRecognition) && faceImageGrouping.isFaceImageAllowed == false:
            openPeopleAlbumWarningPopUp(mode: .bothDisabled)

        default:
            assertionFailure("Logic issue, please check permissions and faceImageGrouping responses")
        }
    }

    private func openPeopleAlbumWarningPopUp(mode: HideFuncPeopleAlbumWarningPopUp.Mode) {
        let controller = HideFuncPeopleAlbumWarningPopUp(mode: mode, delegate: self)
        router.presentViewController(controller: controller, animated: false)
    }
    
    private func openPeopleAlbum() {
        let router = RouterVC()
        let controller = router.peopleListController()

        router.pushViewController(viewController: controller)
    }
}

//MARK: - Interactor

extension HideFunctionalityService {
    private func hidePhotos() {
        player.remove(listItems: items)
        fileService.hide(items: items, success: { [weak self] in
            DispatchQueue.main.async {
                self?.hiddenSuccessfully()
            }

        }, fail: { [weak self] error in
            let errorResponse = ErrorResponse.error(error)
            self?.fail?(errorResponse)

        })
    }

    private func getPermissions() {
        accountService.permissions { [weak self] response in
            switch response {
            case .success(let permissions):
                self?.permissions = permissions

            case .failed(let error):
                let errorResponse = ErrorResponse.error(error)
                self?.fail?(errorResponse)

            }

            self?.peopleAlbumRequestsGroup?.leave()
        }
    }

    private func getFaceImageGroupingStatus() {
        accountService.getSettingsInfoPermissions { [weak self] response in
            switch response {
            case .success(let faceImageGrouping):
                self?.faceImageGrouping = faceImageGrouping

            case .failed(let error):
                let errorResponse = ErrorResponse.error(error)
                self?.fail?(errorResponse)

            }

            self?.peopleAlbumRequestsGroup?.leave()
        }
    }

}

//MARK: - HideFuncRoutingProtoc´ol

extension HideFunctionalityService: HideFuncRoutingProtocol {
    func openHiddenAlbum() {
        //TODO: open hidden album
    }

    func openPeopleAlbumIfPossible() {
        preparePeopleAlbumOpenning()
    }
    
    func openPremium() {
        let controller = router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember)
        router.pushViewController(viewController: controller)
    }

    func openFaceImageGrouping() {
        let controller = router.faceImage
        router.pushViewController(viewController: controller)
    }
}
