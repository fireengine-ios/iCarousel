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
        debugLog("AlbumDetailService allItems")

        currentPage = 0
        requestSize = 90000
        nextItems(albumUUID: albumUUID, sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    func nextItems(albumUUID: String, sortBy: SortType, sortOrder: SortOrder, success: ListRemoveItems?, fail: FailRemoteItems?) {
        debugLog("AlbumDetailService nextItems")

        let serchParam = AlbumDetalParameters (albumUuid: albumUUID, sortBy: sortBy, sortOrder: sortOrder, page: currentPage, size: requestSize)
        
        remote.searchContentAlbum(param: serchParam, success: { response in
            guard let resultResponse = (response as? AlbumDetailResponse)?.list else {
                fail?()
                return
            }
            debugLog("AlbumDetailService nextItems SearchService searchContentAlbum success")

            let list = resultResponse.flatMap { WrapData(remote: $0) }
            self.currentPage = self.currentPage + 1
            success?(list)
        }, fail: { error in
            debugLog("AlbumDetailService nextItems SearchService searchContentAlbum fail")
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
            guard let coverPhoto = (response as? AlbumDetailResponse)?.coverPhoto else {
                fail()
                return
            }
            debugLog("AlbumDetailService albumCoverPhoto success")

            success(WrapData(remote: coverPhoto))
        }, fail: { error in
            debugLog("AlbumDetailService albumCoverPhoto fail")
            error.showInternetErrorGlobal()
            fail()
        })
    }
}
