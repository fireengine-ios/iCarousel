//
//  ActivityTimelineParameters.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ActivityTimelineParameters: BaseRequestParametrs {
    
    private struct ActivityTimelinePath {
        static let pagedGet = "filesystem/activityFeed?sortBy=%@&sortOrder=%@&page=%d&size=%d"
    }
    
    let sortBy: SortType
    let sortOrder: SortOrder
    let page: Int
    let size: Int
    
    init(sortBy: SortType = .name, sortOrder: SortOrder = .asc, page: Int, size: Int) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.page = page
        self.size = size
    }
    
    override var patch: URL {
        let searchWithParam = String(format: ActivityTimelinePath.pagedGet,
                                     sortBy.description,
                                     sortOrder.description,
                                     page,
                                     size)
        
        return URL(string: searchWithParam, relativeTo: super.patch)!
    }
}
