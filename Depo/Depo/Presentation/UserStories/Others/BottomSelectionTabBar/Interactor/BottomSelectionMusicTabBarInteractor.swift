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

    override func shareViaLink(sourceRect: CGRect?){
        output?.operationStarted(type: .share)
        fileService.share(sharedFiles: sharingItems, success: {[weak self] (url) in
            DispatchQueue.main.async {
                self?.output?.operationFinished(type: .share)
                
                let objectsToShare = [url]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                if let tempoRect = sourceRect {//if ipad
                    activityVC.popoverPresentationController?.sourceRect = tempoRect
                }
    
                let topVC = UIApplication.topController()
                topVC?.present(activityVC, animated:  true)

            }
            
            }, fail: failAction(elementType: .share))
    }
   
    override func move(item: [BaseDataSourceItem], toPath:String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let router = RouterVC()
        let folderSelector = router.selectFolder(folder: nil)
        folderSelector.selectFolderBlock = { [weak self] (folder) in
            self?.output?.operationStarted(type: .move)
            self?.fileService.move(items: item, toPath: folder.uuid,
                                   success: self?.succesAction(elementType: .move),
                                   fail: self?.failAction(elementType: .move))
            
        }
        folderSelector.cancelSelectBlock = {
            self.succesAction(elementType: ElementTypes.move)()
        }
        
        let topVC = UIApplication.topController()
        let nContr = UINavigationController(rootViewController: folderSelector)
        nContr.navigationBar.isHidden = false
        topVC?.present(nContr, animated: true, completion: nil)
        
    }
}
