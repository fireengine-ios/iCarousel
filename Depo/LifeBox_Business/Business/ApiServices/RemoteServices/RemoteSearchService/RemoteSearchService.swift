//
//  RemoteSearchService.swift
//  Depo
//
//  Created by Oleg on 21.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class RemoteSearchService: RemoteItemsService {
    
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .all)
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteItems, fail:@escaping FailRemoteItems ) {
        let searchParam = UnifiedSearchParameters(text: searchText,
                                                  category: fieldValue,
                                                  sortBy: sortBy,
                                                  sortOrder: sortOrder,
                                                  page: currentPage,
                                                  size: requestSize)
        remote.unifiedSearch(param: searchParam, success: { [weak self] response in
            guard let response = response as? UnifiedSearchResponse else {
                fail()
                return
            }
            
            var list = response.itemsList.flatMap { WrapData(remote: $0) }
            list.append(contentsOf: response.peopleList.flatMap { PeopleItem(response: $0) })
            list.append(contentsOf: response.thingsList.flatMap { ThingsItem(response: $0) })
            list.append(contentsOf: response.placesList.flatMap { PlacesItem(response: $0) })

            self?.currentPage += 1
            success(list)
        }, fail: { error in
            fail()
        })
    }
    
    func allItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteItems, fail:@escaping FailRemoteItems) {
        currentPage = 0
        requestSize = 90000
        nextItems(searchText, sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
}
