//
//  AlbumDetailService.swift
//  Depo
//
//  Created by Oleg on 24.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AlbumDetailService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .albums)
    }
    
    func allItems(albumUUID: String, sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveItems, fail:@escaping FailRemoteItems) {
        log.debug("AlbumDetailService allItems")

        currentPage = 0
        requestSize = 90000
        nextItems(albumUUID: albumUUID, sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    func nextItems(albumUUID: String, sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?) {
        log.debug("AlbumDetailService nextItems")

        let serchParam = AlbumDetalParameters (albumUuid: albumUUID, sortBy: sortBy, sortOrder: sortOrder, page: currentPage, size: requestSize)
        
        remote.searchContentAlbum(param: serchParam, success: { (response) in
            guard let resultResponse = (response as? AlbumDetailResponse)?.list else {
                fail?()
                return
            }
            log.debug("AlbumDetailService nextItems SearchService searchContentAlbum success")

            let list = resultResponse.flatMap { WrapData(remote: $0) }
            self.currentPage = self.currentPage + 1
            success?(list)
        }, fail: { _ in
            log.debug("AlbumDetailService nextItems SearchService searchContentAlbum fail")

            fail?()
        })
    }
    
}
