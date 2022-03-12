//
//  MapSearchViewOutput.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapSearchViewOutput {
    func viewIsReady()
    func mapRegionChanged(params: MapSearchParams)
    func didSelectGroup(at index: Int)
}
