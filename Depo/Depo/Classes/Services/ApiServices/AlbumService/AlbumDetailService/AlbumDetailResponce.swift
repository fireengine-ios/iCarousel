//
//  AlbumDetailResponce.swift
//  Depo
//
//  Created by Oleg on 24.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct AlbumDetailJsonKey {
    
    static let albumDetailFiles = "fileList"
    
}

class AlbumDetailResponse: ObjectRequestResponse {
    
    var list: Array<SearchItemResponse> = []
    
    override func mapping() {
        let  tmpList = json?[AlbumDetailJsonKey.albumDetailFiles].array
        if let result = tmpList?.flatMap({ SearchItemResponse(withJSON: $0)}){
            list = result
//            let wrapedItems: [WrapData] = result.map {
//               return WrapData(remote: $0)
//            }
//            CoreDataStack.default.appendOnlyNewItems(items: wrapedItems)
            
        }
    }
}
