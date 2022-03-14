//
//  MapSearchPresenter.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import CoreLocation

final class MapSearchPresenter {
    private static let minimumZoomLevel = 3
    private static let maximumZoomLevel = 21

    weak var view: MapSearchViewInput!
    var interactor: MapSearchInteractorInput!
    var router: MapSearchRouterInput!

    private var groups: [MapMediaGroup] = []
}

extension MapSearchPresenter: MapSearchViewOutput {
    func viewIsReady() {
        view.setZoomRange(minimumZoomLevel: Self.minimumZoomLevel, maximumZoomLevel: Self.maximumZoomLevel)
    }

    func mapRegionChanged(params: MapSearchParams) {
        view.showLoading()
        interactor.fetchMediaGroups(params: params)
    }

    func didSelectGroup(at index: Int) {
        guard index >= 0 && index < groups.count else { return }
        router.openMapLocationDetail(for: groups[index])
    }
}

extension MapSearchPresenter: MapSearchInteractorOutput {
    func receivedMediaGroups(_ groups: [MapMediaGroup]) {
        self.groups = groups
        view.hideLoading()
        view.setCurrentGroups(groups)
    }
}
