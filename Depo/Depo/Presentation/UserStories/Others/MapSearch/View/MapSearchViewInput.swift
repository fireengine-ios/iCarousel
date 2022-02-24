//
//  MapSearchViewInput.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol MapSearchViewInput: AnyObject {
    func showLoading()
    func hideLoading()
    func setZoomRange(minimumZoomLevel: Int, maximumZoomLevel: Int)
    func setCurrentGroups(_ groups: [MapMediaGroup])
}
