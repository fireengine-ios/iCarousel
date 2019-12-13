//
//  BottomSelectionMusicTabBarInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 29.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BottomSelectionMusicTabBarInteractor: BottomSelectionTabBarInteractor {
    
    private var fileService = WrapItemFileService()
    
    override func shareViaLink(sourceRect: CGRect?) {
        output?.operationStarted(type: .share)
        fileService.share(sharedFiles: sharingItems, success: {[weak self] url in
                DispatchQueue.main.async {
    
                    self?.output?.operationFinished(type: .share)                
                    if let output_ = self?.output as? BottomSelectionTabBarInteractorOutput {
                        output_.objectsToShare(rect: sourceRect, urls: [url])
                    }
                }
            }, fail: failAction(elementType: .share))
    }
   
    override func move(item: [BaseDataSourceItem], toPath: String) {
        guard let item = item as? [Item] else {
            return
        }
        let itemsFolders = item.flatMap { $0.parent }
        let router = RouterVC()
        let folderSelector = router.selectFolder(folder: nil)
        folderSelector.selectFolderBlock = { [weak self] folder in
            if itemsFolders.contains(folder) {
                folderSelector.dismiss(animated: true, completion: {
                    self?.output?.showWrongFolderPopup()
                })
                return
            }
            
            self?.output?.operationStarted(type: .move)
            self?.fileService.move(items: item, toPath: folder,
                                   success: self?.succesAction(elementType: .move),
                                   fail: self?.failAction(elementType: .move))
            
        }
        folderSelector.cancelSelectBlock = {
            self.succesAction(elementType: ElementTypes.move)()
        }
        
        if let output_ = output as? BottomSelectionTabBarInteractorOutput {
            output_.selectFolder(folderSelector)
        }

    }
    
    override func delete(item: [BaseDataSourceItem]) {
        if let items = item as? [Item] {
            let okHandler: VoidHandler = { [weak self] in
                self?.output?.operationStarted(type: .delete)
                self?.player.remove(listItems: items)
                self?.fileService.moveToTrash(files: items,
                                              success: self?.succesAction(elementType: .delete),
                                              fail: self?.failAction(elementType: .delete))
            }
            
            if let output_ = output as? BottomSelectionTabBarInteractorOutput {
                output_.deleteMusic(okHandler)
            }
        }
    }
}
