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
    
    
    init(with item: WrapData?) {
        super.init()
        
        guard let item = item else {
            return
        }
        
        url = item.localFileUrl
        
//        switch item.patchToPreview {
//        case let .localMediaContent(path):
//            url = path.urlToFile
//        case let .remoteUrl(remoteUrlToFile):
//            url = remoteUrlToFile
//        }
    }
}


extension AugmentedRealityItem: QLPreviewItem {
    var previewItemURL: URL? {
        return url
    }
}
