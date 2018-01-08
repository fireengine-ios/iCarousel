//
//  BottomSelectionMusicTabBarRouter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 29.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BottomSelectionMusicTabBarRouter: BottomSelectionTabBarRouter {

    override func onInfo(object: Item) {
        guard let fileInfo = RouterVC().fileInfo as? FileInfoViewController else {
            return
        }
        
        let topVC = UIApplication.topController()
        topVC?.navigationController?.pushViewController(fileInfo, animated: true)
        fileInfo.interactor.setObject(object: object)
    }
    
    override func showSelectFolder(selectFolder: SelectFolderViewController) {
        let topVC = UIApplication.topController()
        let nContr = UINavigationController(rootViewController: selectFolder)
        nContr.navigationBar.isHidden = false
        topVC?.present(nContr, animated: true, completion: nil)
    }
    
    override func showShare(rect: CGRect?, urls: [String]) {
        let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        
        if let tempoRect = rect {//if ipad
            activityVC.popoverPresentationController?.sourceRect = tempoRect
        }
        let topVC = UIApplication.topController()
        topVC?.present(activityVC, animated:  true)
    }
    
    override func showDeleteMusic(_ completion: @escaping (() -> Void)) {
        let controller = PopUpController.with(title: TextConstants.actionSheetDelete,
                                              message: TextConstants.deleteAlbums,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: completion)
        })
        
        let topVC = UIApplication.topController()
        topVC?.navigationController?.present(controller, animated: true)
    }
    
}
