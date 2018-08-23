//
//  AugumentRealityDetailItem.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook


final class AugmentedRealityItem: NSObject {
    
    private var url: URL?
    private var title: String?
    
    
    init(with item: WrapData?) {
        super.init()
        
        guard let item = item else {
            return
        }
        
        url = item.localFileUrl
        title = item.name
    }
}


extension AugmentedRealityItem: QLPreviewItem {
    var previewItemURL: URL? {
        return url
    }
    
    var previewItemTitle: String? {
        return title
    }
}
