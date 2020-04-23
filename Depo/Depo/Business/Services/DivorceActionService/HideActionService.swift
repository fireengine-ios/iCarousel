//
//  HideActionService.swift
//  Depo
//
//  Created by Raman Harhun on 2/18/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol HideActionServiceProtocol {
    func startOperation(for items: HideActionService.Items,
                        output: BaseAsyncOperationInteractorOutput?,
                        success: @escaping FileOperation,
                        fail: @escaping FailResponse)
}

final class HideActionService: CommonDivorceActionService {
    enum Items {
        case photos(_ photos: [Item])
        case albums(_ albums: [AlbumItem])
    }
    
    private lazy var player: MediaPlayer = factory.resolve()
    private lazy var fileService = WrapItemFileService()
    
    private var items: Items?

    private weak var output: BaseAsyncOperationInteractorOutput?

    private var success: FileOperation?
    private var fail: FailResponse?
}

extension HideActionService: HideActionServiceProtocol {
    func startOperation(for items: Items,
                        output: BaseAsyncOperationInteractorOutput?,
                        success: @escaping FileOperation,
                        fail: @escaping FailResponse) {
        self.items = items
        
        self.output = output
        
        self.fail = fail
        self.success = success
        
        startOperation()
    }
}

//MARK: - DivorceActionPopUpPresentProtocol
extension HideActionService {
    override var state: HSCompletionPopUpsFactory.State {
        switch items {
        case .photos:
            return (output is AlertFilesActionsSheetPresenter) ? .actionSheetHideCompleted : .bottomBarHideCompleted
            
        case .albums:
            return .hideAlbumsCompleted
            
        default:
            assertionFailure(items.debugDescription)
            return .bottomBarHideCompleted
        }
    }
    
    override var itemsCount: Int {
        switch items {
        case .photos(let photos):
            return photos.count
            
        case .albums(let albums):
            return albums.count
            
        default:
            assertionFailure(items.debugDescription)
            return 0
        }
    }
    
    override var confirmPopUp: BasePopUpController {
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analytics.trackFileOperationPopupGAEvent(operationType: .hide, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analytics.trackFileOperationPopupGAEvent(operationType: .hide, label: .ok)
            
            (self?.output as? MoreFilesActionsInteractorOutput)?.operationStarted(type: .hide)
            
            vc.close { [weak self] in
                self?.hideItems()
            }
        }
        
        analytics.logScreen(screen: .fileOperationConfirmPopup(.hide))
        analytics.trackDimentionsEveryClickGA(screen: .fileOperationConfirmPopup(.hide))
        
        return PopUpController.with(title: TextConstants.hideItemsWarningTitle,
                                    message: makeConfirmMessage(),
                                    image: .hide,
                                    firstButtonTitle: TextConstants.cancel,
                                    secondButtonTitle: TextConstants.ok,
                                    firstAction: cancelHandler,
                                    secondAction: okHandler)
    }
}

//MARK: - DivorceActionAnalyticsProtocol
extension HideActionService {
    override func trackConfirmPopUpAppear() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.HideConfirmPopUp())
    }
}

//MARK: - Hide
extension HideActionService {
    private func hideItems() {
        guard let operationItem = items else {
            return
        }
        
        output?.startAsyncOperationDisableScreen()

        switch operationItem {
        case .photos(let items):
            hidePhotos(items)
            
        case .albums(let albums):
            hideAlbums(albums)
        }
    }

    private func hidePhotos(_ items: [Item]) {
        player.remove(listItems: items)
        analytics.trackFileOperationGAEvent(operationType: .hide, items: items)
        fileService.hide(items: items, success: { [weak self] in
            DispatchQueue.main.async {
                self?.onSuccess()
            }

        }, fail: { [weak self] error in
            let errorResponse = ErrorResponse.error(error)
            self?.fail?(errorResponse)

        })
    }

    private func hideAlbums(_ albums: [AlbumItem]) {
        analytics.trackAlbumOperationGAEvent(operationType: .hide, albums: albums)
        fileService.hide(albums: albums, success: { [weak self] in
            DispatchQueue.main.async {
                self?.onSuccess()
            }

        }, fail: { [weak self] error in
            let errorResponse = ErrorResponse.error(error)
            self?.fail?(errorResponse)

        })
    }
    
    private func onSuccess() {
        success?()
        showSuccessPopUp()
    }
}

//MARK: - Builder
extension HideActionService {
    private func makeConfirmMessage() -> String {
        guard let operationItems = items else {
            assertionFailure(items.debugDescription)
            return ""
        }
        
        switch operationItems {
        case .photos(let photos):
            return photos.count > 1 ?
                TextConstants.hideItemsWarningMessage : TextConstants.hideSinglePhotoCompletionAlertMessage
        case .albums(let albums):
            return albums.count > 1 ?
                TextConstants.hideAlbumsWarningMessage : TextConstants.hideSingleAlbumWarnigMessage
        }
    }
}
