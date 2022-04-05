//
//  MapSearchInteractor.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapSearchInteractor {
    weak var output: MapSearchInteractorOutput!

    private let mapSearchService: MapSearchService
    private var currentFetchTask: URLSessionTask?

    init(mapSearchService: MapSearchService = MapSearchService()) {
        self.mapSearchService = mapSearchService
    }
}

extension MapSearchInteractor: MapSearchInteractorInput {
    func fetchMediaGroups(params: MapSearchParams) {
        currentFetchTask?.cancel()

        currentFetchTask = mapSearchService.getMediaGroups(at: params.zoomLevel,
                                                           northWest: params.northWest,
                                                           southEast: params.southEast) { [weak self] response in
            switch response {
            case let .success(results):
                self?.output.receivedMediaGroups(results)
            case let .failed(error):
                guard !error.isNSURLErrorCancelled else {
                    return
                }

                self?.output.receivedMediaGroups([])
            }
        }
    }
}
