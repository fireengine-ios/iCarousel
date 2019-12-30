//
//  HideSmashCoordinator.swift
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
    func startSmashOperation(for item: Item, success: @escaping FileOperation, fail: @escaping FailResponse)
    func startHideOperation(for items: [Item], success: @escaping FileOperation, fail: @escaping FailResponse)
    func startHideSimpleOperation(for items: [Item], success: @escaping FileOperation, fail: @escaping FailResponse)
}

final class HideFunctionalityService: HideFuncServiceProtocol {

    enum Operation {
        case hide
        case hideSimple
        case smash
    }

    //MARK: Properties
    
    private var operation: Operation = .hide

    private var items = [Item]()
    
    private var success: FileOperation?
    private var fail: FailResponse?
    
    private var permissions: PermissionsResponse?
    private var faceImageGrouping: SettingsInfoPermissionsResponse?
    
    private lazy var fileService = WrapItemFileService()
    private lazy var player: MediaPlayer = factory.resolve()
    
    private lazy var completionPopUpFactory = HSCompletionPopUpsFactory()
    private lazy var albumWarningPopUpsFactory = SmartAlbumWarningPopUpsFactory()

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

    func startSmashOperation(for item: Item, success: @escaping FileOperation, fail: @escaping FailResponse) {
        self.items = [item]
        self.success = success
        self.fail = fail

        operation = .smash

        startSmashPhoto()
    }

    func startHideOperation(for items: [Item], success: @escaping FileOperation, fail: @escaping FailResponse) {
        self.items = items
        self.success = success
        self.fail = fail

        operation = .hide

        showConfirmationPopUp()
    }
    
    func startHideSimpleOperation(for items: [Item], success: @escaping FileOperation, fail: @escaping FailResponse) {
        self.items = items
        self.success = success
        self.fail = fail

        operation = .hideSimple

        showConfirmationPopUp()
    }

    //MARK: Utility Methods (Private)

    // Smash
    private func startSmashPhoto() {
        //Smash functionality now developed yet

        //...
        //smashing photo
        //0%
        //20%
        //40%
        //60%
        //80%
        //100%
        //Photo smashed
        //...

        success?()
        
        showSuccessPopUp()
    }

    // Hide
    private func showConfirmationPopUp() {
        router.presentViewController(controller: confirmationPopUp)
    }

    private func hiddenSuccessfully() {
        success?()

        showSuccessPopUp()
    }

    // Common
    private func showSuccessPopUp() {
        let state = getCompletionState()
        let controller = completionPopUpFactory.getPopUp(for: state, itemsCount: items.count, delegate: self)

        presentPopUp(controller: controller)
    }

    private func preparePeopleAlbumOpenning() {
        let group = DispatchGroup()
        let requiredPreparations = [getPermissions, getFaceImageGroupingStatus]

        requiredPreparations.forEach {
            group.enter()
            $0()
        }

        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.peopleAlbumRequestsGroup = nil

            self?.didObtainPeopleAlbumInfo()
        }

        peopleAlbumRequestsGroup = group
    }

    private func didObtainPeopleAlbumInfo() {
        if permissions?.hasPermissionFor(.faceRecognition) == true, faceImageGrouping?.isFaceImageAllowed == true {
            openPeopleAlbum()

        } else if let controller = albumWarningPopUpsFactory.getPopUp(permissions: permissions,
                                                                      faceImageGrouping: faceImageGrouping,
                                                                      delegate: self) {
            presentPopUp(controller: controller)

        } else {
            assertionFailure("could't create pop up with recieved permissions and faceImageGrouping responses")

        }
    }

    private func presentPopUp(controller: UIViewController) {
        router.presentViewController(controller: controller, animated: false)
    }

    private func openPeopleAlbum() {
        
        router.navigationController?.dismiss(animated: true, completion: {
        
            let controller = self.router.peopleListController()
            self.router.pushViewController(viewController: controller)
        })
    }
}

    //MARK: - Converter

extension HideFunctionalityService {
    private func getCompletionState() -> HSCompletionPopUpsFactory.State {
        let state: HSCompletionPopUpsFactory.State

        switch operation {
        case .hide:
            state = .hideCompleted
            
        case .smash:
            state = .smashCompleted
            
        case .hideSimple:
            state = .hideSimpleCompleted
        }
        
        return state
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

//MARK: - HideFuncRoutingProtocol

extension HideFunctionalityService: HideFuncRoutingProtocol {
    func openHiddenAlbum() {
        
        router.navigationController?.dismiss(animated: true, completion: {
            
            let controller = self.router.hiddenPhotosViewController()
            self.router.pushViewController(viewController: controller)
        })
        
    }

    func openPeopleAlbumIfPossible() {
        preparePeopleAlbumOpenning()
    }
    
    func openPremium() {
        
        router.navigationController?.dismiss(animated: true, completion: {
            let controller = self.router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember)
            self.router.pushViewController(viewController: controller)
        })
    }
    
    func openFaceImageGrouping() {
        
        router.navigationController?.dismiss(animated: true, completion: {
            
            if self.faceImageGrouping?.isFaceImageAllowed == true {
                self.openPeopleAlbum()
            } else {
                let controller = self.router.faceImage
                self.router.pushViewController(viewController: controller)
            }
        })
    }
    
}
