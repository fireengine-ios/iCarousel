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

    static let height: CGFloat = 198
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = .lrBrownishGrey
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 2
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = .lrBrownishGrey
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 24)
        }
    }
 
    weak var delegate: AlbumsSliderCellDelegate?
    
    private lazy var dataSource = AlbumsSliderDataSource(collectionView: collectionView, delegate: self)
 
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.selectedItems
    }
    
    //MARK: - 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .lrSkinTone
    }
    
    func setup(title: String, emptyText: String) {
        titleLabel.text = title
        emptyLabel.text = emptyText
    }

    func appendItems(_ newItems: [BaseDataSourceItem]) {
        dataSource.appendItems(newItems)
        emptyLabel.isHidden = !dataSource.items.isEmpty
    }
    
    func reset() {
        dataSource.reset()
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
