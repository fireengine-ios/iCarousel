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
    func openPeopleAlbumIfPossible()
}

protocol HideFuncServiceProtocol {
    func startHideOperation(for items: [Item], output: BaseAsyncOperationInteractorOutput?, success: @escaping FileOperation, fail: @escaping FailResponse)
    func startHideSimpleOperation(for items: [Item], output: BaseAsyncOperationInteractorOutput?, success: @escaping FileOperation, fail: @escaping FailResponse)
    func startHideAlbumsOperation(for albums: [AlbumItem], output: BaseAsyncOperationInteractorOutput?, success: @escaping FileOperation, fail: @escaping FailResponse)
}

final class HideFunctionalityService: HideFuncServiceProtocol {

    enum Operation {
        case hide
        case hideSimple
        case hideAlbums
        case smash
        
        func confirmationTitle(itemsCount: Int) -> String {
            if self == .hideAlbums && itemsCount == 1 {
                return TextConstants.hideItemsWarningTitle
            }
            return TextConstants.hideItemsWarningTitle
        }
 
        func confirmationMessage(itemsCount: Int) -> String {
            switch self {
            case .hide, .hideSimple, .smash:
                return itemsCount > 1 ? TextConstants.hideItemsWarningMessage : TextConstants.hideSinglePhotoCompletionAlertMessage
            case .hideAlbums:
                return itemsCount > 1 ? TextConstants.hideAlbumsWarningMessage : TextConstants.hideSingleAlbumWarnigMessage
            }
        }
    }

    //MARK: Properties
    
    private var operation: Operation = .smash

    private var items = [Item]()
    private var albums = [AlbumItem]()
    private weak var output: BaseAsyncOperationInteractorOutput?

    private var success: FileOperation?
    private var fail: FailResponse?
    
    private var permissions: PermissionsResponse?
    private var faceImageGrouping: SettingsInfoPermissionsResponse?
    
    private lazy var fileService = WrapItemFileService()
    private lazy var hiddenService = HiddenService()
    private lazy var player: MediaPlayer = factory.resolve()
    
    private lazy var completionPopUpFactory = HSCompletionPopUpsFactory()
    private lazy var albumWarningPopUpsFactory = SmartAlbumWarningPopUpsFactory()

    private let router = RouterVC()
    
    private var peopleAlbumRequestsGroup: DispatchGroup?

    //MARK: PopUp

    private var confirmationPopUp: UIViewController {
        let itemsCount = operation == .hideAlbums ? albums.count : items.count
        
        return PopUpController.with(title: operation.confirmationTitle(itemsCount: itemsCount),
                                    message: operation.confirmationMessage(itemsCount: itemsCount),
                                    image: .hide,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    secondAction: { popUp in
                                        popUp.close { [weak self] in
                                            self?.hideItems()
                                        }
        })
    }

    //MARK: Service

    private lazy var accountService: AccountServicePrl = AccountService()

    //MARK: Utility Methods (Public)
    func startHideOperation(for items: [Item],
                            output: BaseAsyncOperationInteractorOutput?,
                            success: @escaping FileOperation,
                            fail: @escaping FailResponse)
    {
        self.items = items
        self.output = output
        self.success = success
        self.fail = fail

        operation = .hide

        showConfirmationPopUp()
    }
    
    func startHideSimpleOperation(for items: [Item],
                                  output: BaseAsyncOperationInteractorOutput?,
                                  success: @escaping FileOperation,
                                  fail: @escaping FailResponse)
    {
        self.items = items
        self.output = output
        self.success = success
        self.fail = fail

        operation = .hideSimple

        showConfirmationPopUp()
    }
    
    func startHideAlbumsOperation(for albums: [AlbumItem],
                                  output: BaseAsyncOperationInteractorOutput?,
                                  success: @escaping FileOperation,
                                  fail: @escaping FailResponse)
    {
        self.albums = albums
        self.output = output
        self.success = success
        self.fail = fail

        operation = .hideAlbums

        showConfirmationPopUp()
    }

    //MARK: Utility Methods (Private)

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
        let itemsCount = operation == .hideAlbums ? albums.count : items.count
        let controller = completionPopUpFactory.getPopUp(for: state, itemsCount: itemsCount, delegate: self)

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

    private func presentPopUp(controller: BasePopUpController) {
        ///if operation started without HideFuncServiceProtocol this mean smash operation
        ///that's why smash operation is default operation
        ///dismissCompletion is required because HideFunctionalityService is contained in OverlayStickerViewController
        if operation == .smash {
            controller.dismissCompletion = { [weak self] in
                let presentedController = self?.router.defaultTopController as? OverlayStickerViewController
                presentedController?.dismiss(animated: true)
            }
        }

        router.defaultTopController?.present(controller, animated: false)
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
            
        case .hideAlbums:
            state = .hideAlbumsCompleted
        }
        
        return state
    }
}

//MARK: - Interactor

extension HideFunctionalityService {
    
    private func hideItems() {
        output?.startAsyncOperationDisableScreen()

        if operation == .hideAlbums {
            hideAlbums()
        } else {
            hidePhotos()
        }
    }
    
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
    
    private func hideAlbums() {
        
        let wrappedSuccessOperation: FileOperationSucces = {
            MediaItemOperationsService.shared.hide(self.albums, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.hiddenSuccessfully()
                }
                
            })
        }
        
        hiddenService.hideAlbums(albums) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                self.fail?(.error(error))
            }
        }
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
