//
//  GalleryCollectionGridSize.swift
//  Depo
//
//  Created by Hady on 5/16/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

enum GalleryCollectionGridSize: Int {
    case three = 3
    case four = 4
    case six = 6

    var next: Self? {
        switch self {
        case .three: return .four
        case .four: return .six
        case .six: return nil
        }
    }

    var previous: Self? {
        switch self {
        case .three: return nil
        case .four: return .three
        case .six: return .four
        }
    }
}
