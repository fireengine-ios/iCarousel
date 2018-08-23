//
//  AugumentRealityDataSource.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook


protocol AugmentedRealityDataSourceDelegate: class {
    func didUpdateARItem()
    func didFailToUpdateARItem(with errorMessage: String?)
}


final class AugmentedRealityDataSource: QLPreviewControllerDataSource {
    
    weak var delegate: AugmentedRealityDataSourceDelegate?
    
    private var item: WrapData
    private var arItem: AugmentedRealityItem
    private var fileProvider = AugmentedRealityFileProvider()
    
    
    init(with item: WrapData) {
        self.item = item
        arItem = AugmentedRealityItem(with: item.localFileUrl, title: item.name)
    }
    
    
    func updateARItem() {
        guard arItem.previewItemURL == nil else {
            delegate?.didUpdateARItem()
            return
        }
        
        fileProvider.downloadFile(item: item, success: { [weak self] localUrl in
            self?.arItem.previewItemURL = localUrl
            self?.delegate?.didUpdateARItem()
        }, fail: { [weak self] error in
            self?.delegate?.didFailToUpdateARItem(with: error)
        })
    }
    

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        //always return 1 for an usdz item
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return arItem
    }
    
}
