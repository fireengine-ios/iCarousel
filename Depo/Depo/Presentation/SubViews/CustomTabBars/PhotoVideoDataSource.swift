//
//  PhotoVideoDataSource.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoDataSourceDelegate: class {
    func selectedModeDidChange(_ selectingMode: Bool)
}

// TODO: selectedIndexPaths NSFetchedResultsController changes
final class PhotoVideoDataSource {
    var isSelectingMode = false {
        didSet {
            delegate?.selectedModeDidChange(isSelectingMode)
        }
    }
    var selectedIndexPaths = Set<IndexPath>()
    weak var delegate: PhotoVideoDataSourceDelegate?
}
