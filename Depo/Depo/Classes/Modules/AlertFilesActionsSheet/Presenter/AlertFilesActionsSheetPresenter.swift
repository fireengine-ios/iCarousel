//
//  AlertFilesActionsSheetPresenter.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class AlertFilesActionsSheetPresenter: MoreFilesActionsPresenter, AlertFilesActionsSheetModuleInput {
    
    let rightButtonBox = CGRect(x: Device.winSize.width - 50, y: 64, width: 10, height: 10)
    //MARK: Module Input
    
    func showSelectionsAlertSheet() {
        let actions = constractActions(with: [.select, .selectAll], for: nil)
        presentAlertSheet(with: actions, presentedBy: nil)
    }
    
    func showAlertSheet(with types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        presentAlertSheet(with: constractActions(with: types, for: nil), presentedBy: sender)
    }
    
    func showAlertSheet(with items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        guard let items = items as? [Item], items.count > 0 else {
            return
        }
        let actions = constractActions(with: adjastActionTypes(for: items), for: nil)
        presentAlertSheet(with: actions, presentedBy: sender)
    }
    
    func showAlertSheet(with types: [ElementTypes], items: [BaseDataSourceItem],
                        presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        
        let actions = constractSpecifiedActions(with: types, for: items)
        presentAlertSheet(with: actions, presentedBy: sender)
    }
    
    func showSpecifiedAlertSheet(with item: BaseDataSourceItem, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController? = nil) {
        
        let headerAction = UIAlertAction(title: item.name ?? "file", style: .default, handler: {_ in
            
        })
        headerAction.isEnabled = false
        
        var types: [ElementTypes] = [.info, .share, .move]
        
        guard let item = item as? Item else {
            return
        }
        types.append(item.favorites ? .removeFromFavorites : .addToFavorites)
        types.append(.delete)
        
        let actions = constractActions(with: types, for: [item])
        
        presentAlertSheet(with: [headerAction] + actions, presentedBy: sender, viewController: viewController)
    }
    
    private func adjastActionTypes(for items: [Item]) -> [ElementTypes] {
        var actionTypes: [ElementTypes] = []
        if items.count == 1, let item = items.first {
            
            switch item.fileType {
            case .audio:
                //This on for player
                actionTypes = [.musicDetails, .addToPlaylist]//, .move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append(.delete)
                
            case .folder:
                break
            case .image:
                actionTypes = [.createStory, .move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.albums != nil) ? .removeFromAlbum : .addToAlbum)
                actionTypes.append((item.syncStatus == .notSynced) ? .backUp : .addToCmeraRoll)
            case .video:
                actionTypes = [.move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.syncStatus == .notSynced) ? .backUp : .addToCmeraRoll)
                
            case .photoAlbum: // TODO add for Alboum
                break
                
            case .musicPlayList: // TODO Add for MUsic
                break
                
            case .application(let fileExtencion):
                switch fileExtencion {
                    
                case .rar, .zip:
                    actionTypes = [.copy, .move]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.delete)
                    
                case .doc, .pdf, .txt, .ppt, .xls, .html:
                    actionTypes = [.move, .copy, .documentDetails]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.delete)
                    
                default:
                    break
                }
            default:
                break
            }
            
        }
        return actionTypes
    }
    
    override func infoAction() {
        debugPrint("info File acton pressed, no action available")
        //        self.router.onInfo(object: currentItems.first!)
        //        self.view.unselectAll()
    }
    
    private func constractSpecifiedActions(with types: [ElementTypes],
                                           for items: [BaseDataSourceItem]?) -> [UIAlertAction] {
        var filteredActionTypes = types
        if let unwrapedItems = items as? [Item] {
            unwrapedItems.forEach({
                if $0.favorites {//works only if there is no favorite types in initial types array
                    if !filteredActionTypes.contains(.removeFromFavorites) {
                        filteredActionTypes.append(.removeFromFavorites)
                    }
                } else {
                    if !filteredActionTypes.contains(.addToFavorites) {
                        filteredActionTypes.append(.addToFavorites)
                    }
                }
                
            })
        }
        filteredActionTypes.append(.selectAll)
        return constractActions(with: filteredActionTypes, for: items)
    }
    
    private func constractActions(with types: [ElementTypes],
                                  for items: [BaseDataSourceItem]?) -> [UIAlertAction] {
        
        var filteredTypes = types
        let langCode = Device.locale
        if langCode != "tr", langCode != "en" {
            filteredTypes = types.filter({$0 != .print})
        }
        
        var tempoItems = items
        if tempoItems == nil {
            guard let wrappedArray = basePassingPresenter?.selectedItems as? [Item] else {
                return []
            }
            tempoItems = wrappedArray
        }
        
        guard let currentItems = tempoItems else {
            return []
        }
        return filteredTypes.map {
            var action: UIAlertAction
            switch $0 {
            case .info:
                action = UIAlertAction(title: TextConstants.actionSheetInfo, style: .default, handler: { _ in
                    self.interactor.info(item: currentItems)
//                    self.view.unselectAll()
                })
            case .edit:
                action = UIAlertAction(title: TextConstants.actionSheetEdit, style: .default, handler: { _ in
                    self.interactor.edit(item: currentItems)
                })
            case .download:
                action = UIAlertAction(title: TextConstants.actionSheetDownload, style: .default, handler: { _ in
                    
                    self.interactor.download(item: currentItems)
                })
            case .delete:
                action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                    
                    self.interactor.delete(item: currentItems)
                })
            case .move:
                action = UIAlertAction(title: TextConstants.actionSheetMove, style: .default, handler: { _ in
                    self.interactor.move(item: currentItems, toPath: "")
                })
            case .share:
                action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
                    self.interactor.share(item: currentItems, sourceRect: nil)
                })
            //Photos and albumbs
            case .photos:
                action = UIAlertAction(title: TextConstants.actionSheetPhotos, style: .default, handler: { _ in
                    self.interactor.photos(items: currentItems)
                })
            case .createAlbum:
                action = UIAlertAction(title: TextConstants.actionSheetAddToAlbum, style: .default, handler: { _ in
                    debugPrint("Can not create album for now")
                })
            case .addToAlbum:
                action = UIAlertAction(title: TextConstants.actionSheetAddToAlbum, style: .default, handler: { _ in
                    self.interactor.addToAlbum(items: currentItems)
                })
            case .albumDetails:
                action = UIAlertAction(title: TextConstants.actionSheetAlbumDetails, style: .default, handler: { _ in
                    self.interactor.albumDetails(items: currentItems)
                })
            case .shareAlbum:
                action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
                    self.interactor.shareAlbum(items: currentItems)
                })
            case .makeAlbumCover:
                action = UIAlertAction(title: TextConstants.actionSheetMakeAlbumCover, style: .default, handler: { _ in
                    self.interactor.makeAlbumCover(items: currentItems)
                })
            case .removeFromAlbum:
                action = UIAlertAction(title: TextConstants.actionSheetRemoveFromAlbum, style: .default, handler: { _ in
                    self.interactor.removeFromAlbum(items: currentItems)
                })
            case .backUp:
                action = UIAlertAction(title: TextConstants.actionSheetBackUp, style: .default, handler: { _ in
                    
                    self.interactor.backUp(items: currentItems)
                })
            case .copy:
                action = UIAlertAction(title: TextConstants.actionSheetCopy, style: .default, handler: { _ in
                    self.interactor.copy(item: currentItems, toPath: "")
                })
            case .createStory:
                action = UIAlertAction(title: TextConstants.actionSheetCreateStory, style: .default, handler: { _ in
                    self.interactor.createStory(items: currentItems)
                })
            case .iCloudDrive:
                action = UIAlertAction(title: TextConstants.actionSheetiCloudDrive, style: .default, handler: { _ in
                    self.interactor.iCloudDrive(items: currentItems)
                })
            case .lifeBox:
                action = UIAlertAction(title: TextConstants.actionSheetLifeBox, style: .default, handler: { _ in
                    self.interactor.lifeBox(items: currentItems)
                })
            case .more:
                action = UIAlertAction(title: TextConstants.actionSheetMore, style: .default, handler: { _ in
                    self.interactor.more(items: currentItems)
                })
            case .musicDetails:
                action = UIAlertAction(title: TextConstants.actionSheetMusicDetails, style: .default, handler: { _ in
                    self.interactor.musicDetails(items: currentItems)
                })
            case .addToPlaylist:
                action = UIAlertAction(title: TextConstants.actionSheetAddToPlaylist, style: .default, handler: { _ in
                    self.interactor.addToPlaylist(items: currentItems)
                })
            case .addToCmeraRoll:
                action = UIAlertAction(title: TextConstants.actionSheetDownloadToCameraRoll, style: .default, handler: { _ in
                    self.interactor.downloadToCmeraRoll(items: currentItems)
                })
            case .addToFavorites:
                action = UIAlertAction(title: TextConstants.actionSheetAddToFavorites, style: .default, handler: { _ in
                    
                    self.interactor.addToFavorites(items: currentItems)
                })
            case .removeFromFavorites:
                action = UIAlertAction(title: TextConstants.actionSheetRemoveFavorites, style: .default, handler: { _ in
                    
                    self.interactor.removeFromFavorites(items: currentItems)
                })
            case .documentDetails:
                action = UIAlertAction(title: TextConstants.actionSheetDocumentDetails, style: .default, handler: { _ in
                    self.interactor.documentDetails(items: currentItems)
                })
                
            case .select:
                action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { _ in
                    self.basePassingPresenter?.selectModeSelected()
                    //                    self.interactor.//TODO: select and select all pass to grid's presenter
                })
            case .selectAll:
                action = UIAlertAction(title: TextConstants.actionSheetSelectAll, style: .default, handler: { _ in
                    self.basePassingPresenter?.selectAllModeSelected()
                    //                    self.interactor.selectAll(items: <#T##[Item]#>)??? //TODO: select and select all pass to grid's presenter
                })
            case .print:
                action = UIAlertAction(title: "Print", style: .default, handler: { _ in
                    //TODO: will be implemented in the next package
                })
            default:
                action = UIAlertAction(title: "TEST", style: .default, handler: { _ in
                    
                })
            }
            return action
        }
    }
    
    private func presentAlertSheet(with actions: [UIAlertAction], presentedBy sender: Any?, onSourceView sourceView: UIView? = nil, viewController: UIViewController? = nil) {
        
        let vc: UIViewController
        
        if let unwrapedVC = viewController {
            vc = unwrapedVC
            
        } else {
            guard let rootVC = RouterVC().navigationController else {
                return
            }
            vc = rootVC
        }
        
        
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: { _ in
            
        })
        let actionsWithCancell = actions + [cancellAction]
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsWithCancell.forEach({actionSheetVC.addAction($0)})
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
            actionSheetVC.popoverPresentationController?.sourceRect = rightButtonBox
        }
        vc.present(actionSheetVC, animated: true, completion: {})
    }
}
