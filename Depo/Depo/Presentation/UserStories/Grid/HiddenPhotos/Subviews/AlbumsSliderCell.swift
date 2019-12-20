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
    func didChangeSelectionAlbumsCount(_ count: Int)
    func needLoadNextAlbumPage()
    func onStartSelection()
}

final class AlbumsSliderCell: UICollectionViewCell {

    static let height: CGFloat = 200
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = UIColor.lrBrownishGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 2
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = UIColor.lrBrownishGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 24)
        }
    }
 
    weak var delegate: AlbumsSliderCellDelegate?
    
    private lazy var dataSource = AlbumsSliderDataSource(collectionView: collectionView, delegate: self)
 
    var selectedItems: [BaseDataSourceItem] {
        return dataSource.selectedItems
    }
    
    var isSelectionActive: Bool {
        return dataSource.isSelectionActive
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
    
    func removeItems(_ items: [BaseDataSourceItem]) {
        dataSource.removeItems(items)
    }
    
    func reset() {
        dataSource.reset()
    }
    
    func finishLoadAlbums() {
        dataSource.isPaginationDidEnd = true
    }
}

//MARK: - Selection State

extension AlbumsSliderCell {

    func startSelection() {
        dataSource.startSelection()
    }
    
    func stopSelection() {
        dataSource.cancelSelection()
    }
}

//MARK: - AlbumsSliderDataSourceDelegate

extension AlbumsSliderCell: AlbumsSliderDataSourceDelegate {
    func didSelect(item: BaseDataSourceItem) {
        delegate?.didSelect(item: item)
    }
    
    func didChangeSelectionCount(_ count: Int) {
        delegate?.didChangeSelectionAlbumsCount(count)
    }
    
    func needLoadNextPage() {
        delegate?.needLoadNextAlbumPage()
    }
    
    func onStartSelection() {
        delegate?.onStartSelection()
    }
}
