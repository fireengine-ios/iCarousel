//
//  RemoteSearchService.swift
//  Depo
//
//  Created by Oleg on 21.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class RemoteSearchService: RemoteItemsService{
    
    init(requestSize:Int) {
        super.init(requestSize: requestSize, fieldValue: .all)
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveItems, fail:@escaping FailRemoteItems ) {
        let searchParam = UnifiedSearchParameters(text: searchText,
                                                  category: fieldValue,
                                                  sortBy: sortBy,
                                                  sortOrder: sortOrder,
                                                  page: currentPage,
                                                  size: requestSize)
        remote.unifiedSearch(param: searchParam, success: { (response) in
            guard let resultResponse = (response as? UnifiedSearchResponse)?.list else {
                fail()
                return
            }
            
            let list = resultResponse.flatMap { WrapData(remote: $0) }
            self.currentPage = self.currentPage + 1
//            CoreDataStack.default.appendOnlyNewItems(items: list)
            success(list)
        }, fail: { error in
            fail()
        })
    }
    
    func allItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveItems, fail:@escaping FailRemoteItems) {
        currentPage = 0
        requestSize = 90000
        nextItems(searchText, sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
}
