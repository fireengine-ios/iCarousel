//
//  MapMediaGroup.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

// MARK: - MapMediaGroup
struct MapMediaGroup: Codable {
    let count: Int
    let point: Point
    let sample: SharedFileInfo
}

// MARK: - Point
extension MapMediaGroup {
    struct Point: Codable {
        let x, y: Double

        var locationCoorindate2D: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: y, longitude: x)
        }
    }
}
