//
//  AugumentRealityDetailItem.swift
//  Depo
//
//  Created by Konstantin on 8/9/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook
import UIKit

class AugumentRealityDetailItem: NSObject {
    
    private var url: URL?
    
    
    init(with item: WrapData?) {
        super.init()
        
        guard let item = item else {
            return
        }
        
        switch item.patchToPreview {
        case let .localMediaContent(path):
            url = path.urlToFile
        case let .remoteUrl(remoteUrlToFile):
            url = remoteUrlToFile
        }
    }
}


extension AugumentRealityDetailItem: QLPreviewItem {
    var previewItemURL: URL? {
        return url
    }
}
