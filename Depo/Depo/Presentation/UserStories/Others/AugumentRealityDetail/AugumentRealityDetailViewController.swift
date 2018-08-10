//
//  AugumentRealityDetailViewController.swift
//  Depo
//
//  Created by Konstantin on 8/9/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook
import UIKit


class AugumentRealityDetailViewController: QLPreviewController {
    
    private var object: WrapData?
    
    
    static func initialize(with object: WrapData) -> AugumentRealityDetailViewController {
        let controller = AugumentRealityDetailViewController()
        controller.object = object
        
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
    }

}

extension AugumentRealityDetailViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        //always return 1 for an usdz item
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return AugumentRealityDetailItem(with: object)
    }
    
    
}
