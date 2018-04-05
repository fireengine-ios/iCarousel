//
//  StoriesDataSourceForCollectionView.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 06.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StoriesDataSourceForCollectionView: ArrayDataSourceForCollectionView {

    override func deleteItems(items: [Item]) {
        super.deleteItems(items: items)
        ItemOperationManager.default.deleteStories(items: items)
    }
    
    override func newStoryCreated() {
        delegate?.needReloadData?()
    }
    
}
