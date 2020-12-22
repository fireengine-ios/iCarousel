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
    
    func allItems(albumUUID: String, sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteItems, fail:@escaping FailRemoteItems) {
        debugLog("AlbumDetailService allItems")

        currentPage = 0
        requestSize = 90000
        nextItems(albumUUID: albumUUID, sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    func nextItems(albumUUID: String, sortBy: SortType, sortOrder: SortOrder, success: ListRemoteItems?, fail: FailRemoteItems?) {
        debugLog("AlbumDetailService nextItems")

        let serchParam = AlbumDetalParameters (albumUuid: albumUUID, sortBy: sortBy, sortOrder: sortOrder, page: currentPage, size: requestSize)
        
        remote.searchContentAlbum(param: serchParam, success: { [weak self] response in
            guard let `self` = self, let resultResponse = response as? AlbumDetailResponse else {
                fail?()
                return
            }

            let list = resultResponse.list.compactMap { WrapData(remote: $0) }
            self.currentPage = self.currentPage + 1
            success?(list)

        }, fail: { error in
            error.showInternetErrorGlobal()
            fail?()
        })
    }
    
    func albumCoverPhoto(albumUUID: String, sortBy: SortType, sortOrder: SortOrder, success: @escaping AlbumCoverPhoto, fail:@escaping FailRemoteItems) {
        debugLog("AlbumDetailService albumFirstItem")
        
        currentPage = 0
        requestSize = 1
        
        let serchParam = AlbumDetalParameters (albumUuid: albumUUID, sortBy: sortBy, sortOrder: sortOrder, page: currentPage, size: requestSize)
        remote.searchContentAlbum(param: serchParam, success: { response in
            guard let resultResponse = response as? AlbumDetailResponse else {
                fail()
                return
            }

            if let photo = resultResponse.coverPhoto {
                success(WrapData(remote: photo))
            }
        }, fail: { error in
            error.showInternetErrorGlobal()
            fail()
        })
    }
}
