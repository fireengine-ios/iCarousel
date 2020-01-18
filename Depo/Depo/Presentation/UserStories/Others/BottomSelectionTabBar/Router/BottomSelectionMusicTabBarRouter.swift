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
        let router = RouterVC()
        let fileInfo = router.fileInfo(item: object)
        router.pushOnPresentedView(viewController: fileInfo)
    }
    
    override func showSelectFolder(selectFolder: SelectFolderViewController) {
        let topVC = UIApplication.topController()
        let nContr = NavigationController(rootViewController: selectFolder)
        nContr.navigationBar.isHidden = false
        topVC?.present(nContr, animated: true, completion: nil)
    }
    
    override func showShare(rect: CGRect?, urls: [String]) {
        let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        let topVC = UIApplication.topController()
        
        if let tempoRect = rect {//if ipad
            activityVC.popoverPresentationController?.sourceRect = tempoRect
            activityVC.popoverPresentationController?.sourceView = topVC?.view
        }
        
        topVC?.present(activityVC, animated: true)
    }
    
    override func showDeleteMusic(_ completion: @escaping VoidHandler) {
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
