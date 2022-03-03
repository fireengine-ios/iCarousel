//
//  MapGroupDetailService.swift
//  Depo
//
//  Created by Hady on 3/1/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import CoreLocation

final class MapLocationDetailService: RemoteItemsService {
    private static let pageSize = 100
    private let coordinate: CLLocationCoordinate2D
    private lazy var mapSearchService = MapSearchService()

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init(requestSize: Self.pageSize, fieldValue: .all) // fieldValue has no meaning here
    }

    override func nextItems(
        sortBy _: SortType,
        sortOrder _: SortOrder,
        success: ListRemoteItems?,
        fail: FailRemoteItems?,
        newFieldValue _: FieldValue? = nil
    ) {
        mapSearchService.getMediaItems(near: coordinate, page: currentPage, size: requestSize) { response in
            switch response {
            case .success(let response):
                success?(response.list.map { WrapData(remote: $0) })
            case .failed:
                fail?()
            }
        }

        currentPage += 1
    }
}
