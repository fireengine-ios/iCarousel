//
//  AlertFilesActionsSheetPresenter.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//
typealias AlertActionsCallback = (_ actions: [UIAlertAction]) -> Void

class AlertFilesActionsSheetPresenter: MoreFilesActionsPresenter, AlertFilesActionsSheetModuleInput {
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    let rightButtonBox = CGRect(x: Device.winSize.width - 45, y: -15, width: 0, height: 0)
    // MARK: Module Input
    
    func showSelectionsAlertSheet() {
        constractActions(with: [.select, .selectAll], for: nil) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: nil)
            }
        }
    }
    
    func showAlertSheet(with types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        self.constractActions(with: types, for: nil) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { /// main thread - no need for weak, but just in case
                    return
                }
                self.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
    }
    
    func showAlertSheet(with items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        guard let items = items as? [Item], items.count > 0 else {
            return
        }
        constractActions(with: adjastActionTypes(for: items), for: nil) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
    }
    
    func showAlertSheet(with types: [ElementTypes], items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        showAlertSheet(with: types, items: items, presentedBy: sender, onSourceView: sourceView, excludeTypes: [ElementTypes]())
    }
    
    func showAlertSheet(with types: [ElementTypes],
                        items: [BaseDataSourceItem],
                        presentedBy sender: Any?,
                        onSourceView sourceView: UIView?,
                        excludeTypes: [ElementTypes]) {
        constractSpecifiedActions(with: types, for: items, excludeTypes: excludeTypes) { [weak self] (actions) in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
        
    }
    
    func showSpecifiedAlertSheet(with item: BaseDataSourceItem, status: ItemStatus, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController? = nil) {
        let headerAction = UIAlertAction(title: item.name ?? "file", style: .default, handler: {_ in
            
        })
        headerAction.isEnabled = false
        
        let types = ElementTypes.specifiedMoreActionTypes(for: status, item: item)
        
        if item is Item || status == .trashed {
            constractActions(with: types, for: [item]) { [weak self] actions in
                DispatchQueue.main.async { [weak self] in
                    self?.presentAlertSheet(with: [headerAction] + actions, presentedBy: sender, viewController: viewController)
                }
            }
        }
    }
    
    func showSpecifiedMusicAlertSheet(with item: WrapData, status: ItemStatus, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?) {
        let types = ElementTypes.muisicPlayerElementConfig(for: status, item: item)
        
        constractActions(with: types, for: [item]) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender, viewController: viewController)
            }
        }
    }
    
    func show(with types: [ElementTypes], for items: [WrapData], presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?) {
        constractActions(with: types, for: items) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender, viewController: viewController)
            }
        }
    }
    
    func showSubPlusSheet(with actions: [UIAlertAction], sender: Any?, viewController: UIViewController?) {
        DispatchQueue.main.async {
            self.presentAlertSheet(with: actions, presentedBy: sender, viewController: viewController)
        }
    }
    
    private func adjastActionTypes(for items: [Item]) -> [ElementTypes] {
        var actionTypes: [ElementTypes] = []
        if items.count == 1, let item = items.first {
            
            switch item.fileType {
            case .audio:
                //This on for player
                actionTypes = [.musicDetails, .addToPlaylist]//, .move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append(.moveToTrash)
                
            case .folder:
                break
            case .image:
                actionTypes = [.move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
                if !item.isLocalItem {
                    actionTypes.append(.moveToTrash)
                }
            case .video:
                actionTypes = [.move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
                
            case .musicPlayList: // TODO Add for MUsic
                break
                
            case .application(let fileExtencion):
                switch fileExtencion {
                    
                case .rar, .zip:
                    actionTypes = [.copy, .move]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.moveToTrash)
                    
                case .doc, .pdf, .txt, .ppt, .xls, .html, .pptx:
                    actionTypes = [.move, .copy, .documentDetails]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.moveToTrash)
                    
                default:
                    break
                }
            default:
                break
            }
            
        }
        return actionTypes
    }
    
    private func constractSpecifiedActions(with types: [ElementTypes],
                                           for items: [BaseDataSourceItem]?,
                                           excludeTypes: [ElementTypes] = [ElementTypes](),
                                           success: @escaping AlertActionsCallback) {
        DispatchQueue.toBackground { [weak self] in
            let filteredActionTypes = types.filter({ !excludeTypes.contains($0) })
            guard let self = self else {
               return
            }
            
            self.constractActions(with: filteredActionTypes, for: items) { actions in
                success(actions)
            }
        }
    }
    
    private func constractActions(with types: [ElementTypes],
                                  for items: [BaseDataSourceItem]?, sender: Any? = nil,
                                  actionsCallback: @escaping AlertActionsCallback) {
        
        var filteredTypes = types
        let langCode = Device.locale
//        if langCode != "tr" {
//            filteredTypes = types.filter({ $0 != .print }) //FE-2439 - Removing Print Option for Turkish (TR) language
//        }
        basePassingPresenter?.getSelectedItems { [weak self] selectedItems in
            //FIXME: this part can actualy be wraped into background thread
            guard let self = self else {
                return
            }
            
            var tempoItems = items
            if tempoItems == nil || tempoItems?.count == 0 {
                tempoItems = selectedItems
            }
            
            guard let currentItems = tempoItems else {
                actionsCallback([])
                return
            }
            actionsCallback(filteredTypes.map { type in
                var action: UIAlertAction
                switch type {
                case .info,
                     .download,
                     .downloadDocument,
                     .moveToTrash,
                     .restore,
                     .move,
                     .emptyTrashBin,
                     .photos,
                     .shareAlbum,
                     .makeAlbumCover,
                     .backUp,
                     .copy,
                     .iCloudDrive,
                     .lifeBox,
                     .more,
                     .musicDetails,
                     .addToPlaylist,
                     .addToCmeraRoll,
                     .addToFavorites,
                     .removeFromFavorites,
                     .documentDetails,
                     .select,
                     .selectAll,
                     .deSelectAll,
                     .rename,
                     .delete,
                     .endSharing,
                     .leaveSharing,
                     .moveToTrashShared,
                     .editorRole,
                     .viewerRole,
                     .variesRole,
                     .removeRole:
                    
                    action = UIAlertAction(title: type.actionTitle, style: .default, handler: { [weak self] _ in
                        self?.handleAction(type: type, items: currentItems)
                    })

                case .share, .privateShare:
                    action = UIAlertAction(title: type.actionTitle, style: .default, handler: { _ in
                        self.handleAction(type: type, items: currentItems, sender: sender)
                    })
                case .undetermend:
                    action = UIAlertAction()
                }
                return action
            })
        }
    }
    
    func onlyPresentAlertSheet(with elements: [ElementTypes], for objects:[Item], sender: Any?) {
        constractActions(with: elements, for: objects) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
    }
    
    private func presentAlertSheet(with actions: [UIAlertAction], presentedBy sender: Any?, onSourceView sourceView: UIView? = nil, viewController: UIViewController? = nil) {
        let vc: UIViewController
        
        if let unwrapedVC = viewController {
            vc = unwrapedVC
            
        } else {
            guard let rootVC = RouterVC().getViewControllerForPresent() else {
                return
            }
            vc = rootVC
        }
        
        
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: { _ in
            
        })
        let actionsWithCancell = actions + [cancellAction]
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsWithCancell.forEach({ actionSheetVC.addAction($0) })
        actionSheetVC.view.tintColor = UIColor.black
        
        actionSheetVC.popoverPresentationController?.sourceView = vc.view
        
        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: vc.view)
            if sourceRectFrame.origin.x > vc.view.bounds.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            
            actionSheetVC.popoverPresentationController?.sourceRect = sourceRectFrame
        } else if let _ = sender as? UIBarButtonItem {
            //FIXME: use actionSheetVC.popoverPresentationController?.barButtonItem instead
            if vc.navigationController?.navigationBar.isTranslucent == true {
                var frame = rightButtonBox
                frame.origin.y = 44
                actionSheetVC.popoverPresentationController?.sourceRect = frame
            } else {
                actionSheetVC.popoverPresentationController?.sourceRect = rightButtonBox
            }
            
            actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up 
        }
        vc.present(actionSheetVC, animated: true, completion: {})
    }
    
    private func getSourceRect(sender: Any?, controller: ViewController?) -> CGRect {
        var newSourceRect = CGRect()
        
        let sourceController: UIViewController
        if let unwrapedVC = controller {
            sourceController = unwrapedVC 
        } else if let rootVC = RouterVC().getViewControllerForPresent() {
            sourceController = rootVC
        } else {
            return newSourceRect
        }
        
        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: sourceController.view)
            if sourceRectFrame.origin.x > sourceController.view.bounds.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            newSourceRect = sourceRectFrame
        } else if let _ = sender as? UIBarButtonItem {
            if sourceController.navigationController?.navigationBar.isTranslucent == true {
                var frame = rightButtonBox
                frame.origin.y = 44
                newSourceRect = frame
            } else {
                newSourceRect = rightButtonBox
            }
        }
        return newSourceRect
    }
    
    func handleAction(type: ElementTypes, items: [BaseDataSourceItem], sender: Any? = nil) {
        trackNetmeraAction(type: type)
        
        switch type {
        case .info:
            interactor.info(item: items)
        case .download:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.download(item: items)
                basePassingPresenter?.stopModeSelected()
            } else {
                let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
        case .downloadDocument:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.downloadDocument(items: items as? [WrapData])
                basePassingPresenter?.stopModeSelected()
            } else {
                let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
        case .moveToTrash:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.moveToTrash(items: items)
            } else {
                let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
            
        case .restore:
            interactor.restore(items: items)
            
        case .move:
            interactor.move(item: items, toPath: "")
            
        case .share:
            interactor.share(item: items, sourceRect: self.getSourceRect(sender: sender, controller: nil))
            
        case .emptyTrashBin:
            interactor.emptyTrashBin()

        //Photos and albumbs
        case .photos:
            interactor.photos(items: items)

        case .shareAlbum:
            interactor.shareAlbum(items: items)
            
        case .makeAlbumCover:
            interactor.makeAlbumCover(items: items)
            
        case .backUp:
            interactor.backUp(items: items)
            
        case .copy:
            interactor.copy(item: items, toPath: "")
            
        case .iCloudDrive:
            interactor.iCloudDrive(items: items)

        case .lifeBox:
            interactor.lifeBox(items: items)
            
        case .more:
            interactor.more(items: items)
            
        case .musicDetails:
            interactor.musicDetails(items: items)
            
        case .addToPlaylist:
            interactor.addToPlaylist(items: items)
            
        case .addToCmeraRoll:
            interactor.downloadToCmeraRoll(items: items)
            
        case .addToFavorites:
            basePassingPresenter?.stopModeSelected()
            interactor.addToFavorites(items: items)
            
        case .removeFromFavorites:
            interactor.removeFromFavorites(items: items)
            basePassingPresenter?.stopModeSelected()
            
        case .documentDetails:
            interactor.documentDetails(items: items)
            
        case .select:
            basePassingPresenter?.selectModeSelected(with: items.first as? Item)
//                    self.interactor.//TODO: select and select all pass to grid's presenter
            
        case .selectAll:
            basePassingPresenter?.selectAllModeSelected()
//                    self.interactor.selectAll(items: <#T##[Item]#>)??? //TODO: select and select all pass to grid's presenter
        
        case .deSelectAll:
            basePassingPresenter?.deSelectAll()
            
        case .rename:
            if let item = items.first as? Item {
                basePassingPresenter?.renamingSelected(item: item)
            }
//            interactor.info(item: items, isRenameMode: true)
            
        case .delete:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.delete(items: items)
            } else {
                let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
        
        case .endSharing:
            //currently only for one file is supported
            interactor.endSharing(item: items.first)
            
        case .leaveSharing:
            //currently only for one file is supported
            self.interactor.leaveSharing(item: items.first)
            
        case .moveToTrashShared:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.moveToTrashShared(items: items)
            } else {
                let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
            
        default:
            break
        }
    }
    
    func handleShare(type: ShareTypes, items: [BaseDataSourceItem], sender: Any?) {
        let sourceRect = getSourceRect(sender: sender, controller: nil)
        interactor.handleShare(type: type, sourceRect: sourceRect, items: items)
    }
    
    private func trackNetmeraAction(type: ElementTypes) {
        var button: NetmeraEventValues.ButtonName?
        
        switch type {
        case .info:
            button = .info
        case .download, .downloadDocument:
            button = .download
        case .moveToTrash,
             .moveToTrashShared,
             .delete:
            button = .delete
        case .restore:
            button = .restore
        case .share, .shareAlbum:
            button = .share
        case .addToFavorites:
            button = .addToFavorites
        case .removeFromFavorites:
            button = .removeFromFavorites
        case .endSharing:
            button = .endSharing
        case .leaveSharing:
            button = .leaveSharing
        default:
            button = nil
        }
        
        if let button = button {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: button))
        }
    }
}
