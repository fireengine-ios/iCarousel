//
//  AlbumsSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol AlbumsSliderViewDelegate: class {
    func didSelect(item: SliderItem)
    func didChangeSelectionCount(_ count: Int)
}

final class AlbumsSliderView: UIView, NibInit {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emptyLabel: UILabel!
 
    weak var delegate: AlbumsSliderViewDelegate?
    
    private lazy var dataSource = AlbumsSliderDataSource(collectionView: collectionView, delegate: self)
 
    var selectedItems: [SliderItem] {
        return dataSource.selectedItems
    }
    
    //MARK: - 
    
    func setup(title: String, emptyText: String) {
        
    }
    
    func setItems(_ newItems: [SliderItem]) {
        dataSource.setItems(newItems)
    }
    
    func appendItems(_ newItems: [SliderItem]) {
        dataSource.appendItems(newItems)
    }
}

//MARK: - AlbumsSliderDataSourceDelegate

extension AlbumsSliderView: AlbumsSliderDataSourceDelegate {
    func didSelect(item: SliderItem) {
        delegate?.didSelect(item: item)
    }
    
    func didChangeSelectionCount(_ count: Int) {
        delegate?.didChangeSelectionCount(count)
    }
}
