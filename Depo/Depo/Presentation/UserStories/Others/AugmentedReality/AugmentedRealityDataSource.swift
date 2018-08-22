//
//  AugumentRealityDataSource.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook


final class AugmentedRealityDataSource: QLPreviewControllerDataSource {
    
    private var item: AugmentedRealityItem
    
    
    init(with arItem: AugmentedRealityItem) {
        item = arItem
    }
    

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        //always return 1 for an usdz item
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return item
    }
    
}
