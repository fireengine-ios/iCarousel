//
//  MapSearchPresenter.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapSearchPresenter {
    private static let minimumZoomLevel = 3
    private static let maximumZoomLevel = 21

    weak var view: MapSearchViewInput!
    var interactor: MapSearchInteractorInput!
    var router: MapSearchRouterInput!
}

extension MapSearchPresenter: MapSearchViewOutput {
    func viewIsReady() {
        view.setZoomRange(minimumZoomLevel: Self.minimumZoomLevel, maximumZoomLevel: Self.maximumZoomLevel)
    }

    func mapRegionChanged(params: MapSearchParams) {
        view.showLoading()
        interactor.fetchMediaGroups(params: params)
    }

    func didSelectGroup(at coordinate: CLLocationCoordinate2D) {
        router.openMapLocationDetail(coordinate: coordinate)
    }
}

extension MapSearchPresenter: MapSearchInteractorOutput {
    func receivedMediaGroups(_ groups: [MapMediaGroup]) {
        view.hideLoading()
        view.setCurrentGroups(groups)
    }
}
