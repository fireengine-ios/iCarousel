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

    static let height: CGFloat = 180
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = UIColor.lrBrownishGrey
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 3
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = UIColor.lrBrownishGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
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
    
    var isEmpty: Bool {
        return dataSource.items.isEmpty
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
    }
    
    func removeItems(_ items: [BaseDataSourceItem], completion: VoidHandler? = nil) {
        dataSource.removeItems(items) { [weak self] in
            self?.checkEmptyLabel()
            completion?()
        }
    }
    
    func reset() {
        emptyLabel.isHidden = true
        dataSource.reset()
    }
    
    func finishLoadAlbums() {
        dataSource.isPaginationDidEnd = true
        checkEmptyLabel()
    }
    
    private func checkEmptyLabel() {
        emptyLabel.isHidden = !dataSource.items.isEmpty
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
