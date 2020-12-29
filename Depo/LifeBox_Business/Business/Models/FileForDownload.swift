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
        //TODO: in future preview URL should optional, if there is no preview url - we show gray thubnail(create story)
        if wrapData.fileType == .video, let videoPreview = wrapData.metaData?.videoPreviewURL {
            url = videoPreview
        } else if let photoPreview = wrapData.metaData?.mediumUrl {
            url = photoPreview
        } else {
            url = wrapData.tmpDownloadUrl
        }
        
        guard let name = wrapData.name, let _url = url else {
            return nil
        }
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
}
