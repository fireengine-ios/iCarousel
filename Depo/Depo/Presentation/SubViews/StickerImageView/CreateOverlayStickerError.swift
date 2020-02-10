//
//  CreateOverlayStickerError.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

enum CreateOverlayStickerError {
    case unknown
    case special
    case emptyAttachment
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
        }
    }
}
