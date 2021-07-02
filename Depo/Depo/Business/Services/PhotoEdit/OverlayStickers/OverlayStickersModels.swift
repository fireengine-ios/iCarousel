//
//  OverlayStickersModels.swift
//  Depo_LifeTech
//
//  Created by Hady on 7/1/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

/* Types used in `PhotoEditSaveService` & `OverlayAnimationService` */

// MARK: CreateOverlayStickersSuccessResult

struct CreateOverlayStickersSuccessResult {
    let url: URL
    let type: CreateOverlayResultType
}

enum CreateOverlayResultType {
    case image
    case video

    var toPHMediaType: PHAssetMediaType {
        switch self {
        case .image:
            return .image
        case .video:
            return .video
        }
    }
}

// MARK: CreateOverlayStickerError

enum CreateOverlayStickerError {
    case unknown
    case special
    case emptyAttachment
    case deniedPhotoAccess
}

extension CreateOverlayStickerError: LocalizedError {
    var errorDescription: String? {
        switch self {

        case .unknown:
            return "Unknown error occure"
        case .special:
            return "Special error occure"
        case .emptyAttachment:
            return "You don't add any effects"
        case .deniedPhotoAccess:
            return "Need access to gallery"
        }
    }
}

typealias CreateOverlayStickersResult = Result<CreateOverlayStickersSuccessResult, CreateOverlayStickerError>
