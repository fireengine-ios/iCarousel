//
//  ShareData.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

open class ShareData {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    var image: UIImage? {
        return #imageLiteral(resourceName: "ImageNoDocuments")
    }
    
    var name: String {
        return url.lastPathComponent
    }
}

final class ShareImage: ShareData {
    override var image: UIImage? {
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }
}

final class ShareVideo: ShareData {
    override var image: UIImage? {
        return url.videoPreview
    }
}
