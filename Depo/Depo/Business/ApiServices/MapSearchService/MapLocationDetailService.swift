//
//  MapGroupDetailService.swift
//  Depo
//
//  Created by Hady on 3/1/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class MapLocationDetailService: RemoteItemsService {
    private static let pageSize = 100
    private let group: MapMediaGroup
    private lazy var mapSearchService = MapSearchService()

    init(group: MapMediaGroup) {
        self.group = group
        super.init(requestSize: Self.pageSize, fieldValue: .all) // fieldValue has no meaning here
    }

    override func nextItems(
        sortBy _: SortType,
        sortOrder _: SortOrder,
        success: ListRemoteItems?,
        fail: FailRemoteItems?,
        newFieldValue _: FieldValue? = nil
    ) {
        mapSearchService.getMediaItems(in: group, page: currentPage, size: requestSize) { response in
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
