//
//  AugumentRealityDetailItem.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook


final class AugmentedRealityItem: NSObject, QLPreviewItem {
    var previewItemURL: URL?
    var previewItemTitle: String?
    
    
    init(with url: URL?, title: String?) {
        super.init()
        
        previewItemURL = url
        previewItemTitle = title
    }
}
