//
//  FileForDownload.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/19/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

struct FileForDownload {
    let url: URL
    let name: String
    let type: FileType
    
    init?(forMediumURL wrapData: WrapData) {
        let url: URL?
        if wrapData.fileType == .video {
            url = wrapData.metaData?.videoPreviewURL
        } else {
            url = wrapData.metaData?.mediumUrl
        }
        
        guard let _url = url, let name = wrapData.name else { return nil }
        self.url = _url
        self.name = name
        self.type = wrapData.fileType
    }
    
    init?(forOriginalURL wrapData: WrapData) {
        guard let url = wrapData.urlToFile, let name = wrapData.name else { return nil }
        self.url = url
        self.name = name
        self.type = wrapData.fileType
    }
    
    init?(forInstaPickAnalyze analyze: InstapickAnalyze?) {
        guard let url = analyze?.getLargeImageURL(), let name = analyze?.fileInfo?.name else { return nil }
        self.url = url
        self.name = name
        self.type = .image
    }
}
