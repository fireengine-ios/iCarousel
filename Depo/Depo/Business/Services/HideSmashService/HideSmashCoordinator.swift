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
    func openHiddenBin()
    func openPeopleAlbumIfPossible()
    //Track events
    func popUPClosed()
    func becomePremium()
    func proceedWithExistingPeople()
}

extension HideFuncRoutingProtocol {
    func popUPClosed() {}
    func becomePremium() {}
    func proceedWithExistingPeople() {}
}

protocol HideFuncServiceProtocol {
    func startHideOperation(for items: [Item], output: BaseAsyncOperationInteractorOutput?, success: @escaping FileOperation, fail: @escaping FailResponse)
    func startHideAlbumsOperation(for albums: [AlbumItem], output: BaseAsyncOperationInteractorOutput?, success: @escaping FileOperation, fail: @escaping FailResponse)
}

protocol SmashServiceProtocol {
    func smashConfirmPopUp(completion: @escaping BoolHandler)
    func smashSuccessed()
}

final class HideSmashCoordinator: HideFuncServiceProtocol, SmashServiceProtocol {

    enum Operation {
        case hide
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
            case .hide, .smash:
                return itemsCount > 1 ? TextConstants.hideItemsWarningMessage : TextConstants.hideSinglePhotoCompletionAlertMessage
            case .hideAlbums:
                return itemsCount > 1 ? TextConstants.hideAlbumsWarningMessage : TextConstants.hideSingleAlbumWarnigMessage
            }
        }
    }

    //MARK: Properties

    private var operation: Operation!

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
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    private let router = RouterVC()

    private var peopleAlbumRequestsGroup: DispatchGroup?

    //MARK: PopUp

    private var confirmationPopUp: UIViewController {
        let itemsCount = operation == .hideAlbums ? albums.count : items.count
        
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            if self?.operation.isContained(in: [.hide, .hideAlbums]) == true {
                self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .hide, label: .cancel)
            }
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            if self?.operation.isContained(in: [.hide, .hideAlbums]) == true {
                self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .hide, label: .ok)
            }
            
            (self?.output as? MoreFilesActionsInteractorOutput)?.operationStarted(type: .hide)
            
            vc.close { [weak self] in
                self?.hideItems()
            }
        }
        
        if operation.isContained(in: [.hide, .hideAlbums]) {
            analyticsService.logScreen(screen: .fileOperationConfirmPopup(.hide))
            analyticsService.trackDimentionsEveryClickGA(screen: .fileOperationConfirmPopup(.hide))
        }
        
        return PopUpController.with(title: operation.confirmationTitle(itemsCount: itemsCount),
                                    message: operation.confirmationMessage(itemsCount: itemsCount),
                                    image: .hide,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    firstAction: cancelHandler,
                                    secondAction: okHandler)
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

    func smashSuccessed() {
        operation = .smash
        showSuccessPopUp()
    }
    
    func smashConfirmPopUp(completion: @escaping (Bool) -> Void) {
        operation = .smash
        let popUp = PopUpController.with(title: TextConstants.save,
                                         message: TextConstants.smashPopUpMessage,
                                         image: .error,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstUrl: nil,
                                         secondUrl: nil,
                                         firstAction: { popup in
                                            completion(false)
                                            popup.close() },
                                         secondAction: { popup in
                                            popup.close()
                                            completion(true)
        })
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SmashConfirmPopUp())
        UIApplication.topController()?.present(popUp, animated: true, completion: nil)
        
    }
    
    //MARK: Utility Methods (Private)

    // Hide
    private func showConfirmationPopUp() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.HideConfirmPopUp())
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
        router.presentViewController(controller: controller, animated: false)
    }
    
    private func push(controller: UIViewController) {
        router.navigationController?.dismiss(animated: true, completion: {
            self.router.pushViewController(viewController: controller)
        })
    }

    private func openPeopleAlbum() {
        push(controller: self.router.peopleListController())
    }
}

    //MARK: - Converter

extension HideSmashCoordinator {
    private func getCompletionState() -> HSCompletionPopUpsFactory.State {
        let state: HSCompletionPopUpsFactory.State

        switch operation! {
        case .hide:
            state = (output is AlertFilesActionsSheetPresenter) ? .actionSheetHideCompleted : .bottomBarHideCompleted

        case .smash:
            state = .smashCompleted

        case .hideAlbums:
            state = .hideAlbumsCompleted
        }

        return state
    }
}

//MARK: - Interactor

extension HideSmashCoordinator {

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
        analyticsService.trackFileOperationGAEvent(operationType: .hide, items: items)
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
        analyticsService.trackAlbumOperationGAEvent(operationType: .hide, albums: albums)
        fileService.hide(albums: albums, success: { [weak self] in
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

extension HideSmashCoordinator: HideFuncRoutingProtocol {

    func openHiddenBin() {
        let controller = router.hiddenPhotosViewController()
        push(controller: controller)
    }
    
    func openPeopleAlbumIfPossible() {
        preparePeopleAlbumOpenning()
    }

    func openPremium() {
        trackEvents(event: .becomePremium)
        let controller = router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember)
        push(controller: controller)
    }

    func openFaceImageGrouping() {
        trackEvents(event: .enable)
        if faceImageGrouping?.isFaceImageAllowed == true {
            openPeopleAlbum()
            analyticsService.logScreen(screen: .standardUserWithFIGroupingOnPopUp)
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.StandardUserFIRGroupingON())
        } else {
            if AuthoritySingleton.shared.accountType.isPremium {
                analyticsService.logScreen(screen: .nonStandardUserWithFIGroupingOffPopUp)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.NonStandardUserFIGroupingOFF())
            } else {
                analyticsService.logScreen(screen: .standardUserWithFIGroupingOffPopUp)
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.StandardUserFIGroupingOFF())
            }
            
            let controller = router.faceImage
            push(controller: controller)
        }
    }
    
    func popUPClosed() {
        (output as? MoreFilesActionsInteractorOutput)?.successPopupClosed()
        trackEvents(event: .cancel)
    }
    
    func becomePremium() {
        trackEvents(event: .becomePremium)
    }
    
    func proceedWithExistingPeople() {
        trackEvents(event: .proceedWithExistingPeople)
    }
}

extension HideSmashCoordinator {
    
    private enum TrackEventsOnPeopleAlbumPopUp {
        case enable
        case becomePremium
        case cancel
        case proceedWithExistingPeople
    }
    
    private func trackEvents(event: TrackEventsOnPeopleAlbumPopUp) {
        var event: GAEventLabel {
            switch event {
            case .enable:
                return GAEventLabel.enableFIGrouping
            case .becomePremium:
                return GAEventLabel.becomePremium
            case .proceedWithExistingPeople:
                return GAEventLabel.proceedWithExistingPeople
            case .cancel:
                return GAEventLabel.cancel
            }
        }

        let action: GAEventAction
        
        if faceImageGrouping?.isFaceImageAllowed == true {
            action = .standardUserWithFIGroupingOn
        } else if AuthoritySingleton.shared.accountType.isPremium {
            action = .nonStandardUserWithFIGroupingOff
        } else {
            action = .standardUserWithFIGroupingOff
        }

        analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                            eventActions: action,
                                            eventLabel: event)
    }
}
