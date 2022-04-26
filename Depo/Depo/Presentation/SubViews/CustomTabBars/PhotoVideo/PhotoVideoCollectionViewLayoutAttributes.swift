//
//  PhotoVideoCollectionViewLayoutAttributes.swift
//  Depo
//
//  Created by Hady on 4/25/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class PhotoVideoCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var isPinned: Bool = false

    override func copy(with zone: NSZone? = nil) -> Any {
        let attributes = super.copy(with: zone) as! Self
        attributes.isPinned = isPinned
        return attributes
    }
}
