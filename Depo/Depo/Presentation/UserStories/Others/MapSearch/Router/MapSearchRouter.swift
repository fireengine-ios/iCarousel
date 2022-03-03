//
//  MapSearchRouter.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapSearchRouter: MapSearchRouterInput {
    private lazy var router = RouterVC()

    func openMapGroupDetail(coordinate: CLLocationCoordinate2D) {
        let viewController = router.mapGroupDetail(coordinate: coordinate)
        router.pushViewController(viewController: viewController)
    }
}
