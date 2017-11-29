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
        let viewContr = router.fileInfo!
        guard let fileInfo = viewContr as? FileInfoViewController else{
            return
        }
        
        let topVC = UIApplication.topController()
        topVC?.navigationController?.pushViewController(fileInfo, animated: true)
        fileInfo.interactor.setObject(object: object)
    }
    
}
