//
//  AlbumCountResponse.swift
//  Depo
//
//  Created by Burak Donat on 21.11.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

struct AlbumCountJsonKey {
    static let imageCount = "imageCount"
    static let videoCount = "videoCount"
    static let audioCount = "audioCount"
}


final class AlbumCountResponse: ObjectRequestResponse {

    var imageCount: Int?
    var videoCount: Int?
    var audioCount: Int?

    override func mapping() {
        imageCount = json?[AlbumCountJsonKey.imageCount].int
        videoCount = json?[AlbumCountJsonKey.videoCount].int
        audioCount = json?[AlbumCountJsonKey.audioCount].int
    }
}
