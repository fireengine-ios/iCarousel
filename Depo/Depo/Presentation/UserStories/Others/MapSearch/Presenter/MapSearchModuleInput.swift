//
//  MapSearchModuleInput.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol MapSearchModuleInput: AnyObject {
    
}

struct MapSearchParams {
    let northWest: CLLocationCoordinate2D
    let southEast: CLLocationCoordinate2D
    let zoomLevel: Int
}
