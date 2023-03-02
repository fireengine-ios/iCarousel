//
//  CollageTemplate.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct CollageTemplateElement: Codable {
    let collageImagePath, smallThumbnailImagePath: String
    let imageWidth, imageHeight, shapeCount: Int
    let shapeDetails: [ShapeDetail]

    // MARK: - ShapeDetail
    struct ShapeDetail: Codable {
        let id: Int
        let type: String
        let cornersCount, sortIndex: Int
        let shapeCoordinates: [ShapeCoordinate]
    }

    // MARK: - ShapeCoordinate
    struct ShapeCoordinate: Codable {
        let x, y: Int
    }
}

typealias CollageTemplate = [CollageTemplateElement]
