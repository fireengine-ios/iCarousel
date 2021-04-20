//
//  SearchDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 14.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class SearchDataSource: BaseDataSourceForCollectionView {
    
    var moreActionItem: Item?
    
    override func addFilesToFavorites(items: [Item]) {
        updateFavoritesCellStatus(items: items, isFavorites: true)
    }
    
    override func removeFileFromFavorites(items: [Item]) {
        updateFavoritesCellStatus(items: items, isFavorites: false)
    }

    
}
