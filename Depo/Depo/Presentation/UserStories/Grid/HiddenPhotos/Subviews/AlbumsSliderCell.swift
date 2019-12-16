//
//  AlbumsSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol AlbumsSliderCellDelegate: class {
    func didSelect(item: BaseDataSourceItem)
    func didChangeSelectionCount(_ count: Int)
    func needLoadNextAlbumPage()
}

final class AlbumsSliderCell: UICollectionViewCell {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emptyLabel: UILabel!
 
    weak var delegate: AlbumsSliderCellDelegate?
    
    private lazy var dataSource = AlbumsSliderDataSource(collectionView: collectionView, delegate: self)
 
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.selectedItems
    }
    
    //MARK: - 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .lightGray
    }
    
    func setup(title: String, emptyText: String) {
        
    }

    func appendItems(_ newItems: [BaseDataSourceItem]) {
        dataSource.appendItems(newItems)
    }
}

//MARK: - Selection State

extension AlbumsSliderCell {
    
}


//MARK: - AlbumsSliderDataSourceDelegate

extension AlbumsSliderCell: AlbumsSliderDataSourceDelegate {
    func didSelect(item: BaseDataSourceItem) {
        delegate?.didSelect(item: item)
    }
    
    func didChangeSelectionCount(_ count: Int) {
        delegate?.didChangeSelectionCount(count)
    }
    
    func needLoadNextPage() {
        delegate?.needLoadNextAlbumPage()
    }
}
