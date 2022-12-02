//
//  AlbumsSliderView.swift
//  Depo
//
//  Created by Andrei Novikau on 12/12/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol AlbumsSliderCellDelegate: AnyObject {
    func didSelect(item: BaseDataSourceItem)
    func didChangeSelectionAlbumsCount(_ count: Int)
    func needLoadNextAlbumPage()
    func onStartSelection()
}

final class AlbumsSliderCell: UICollectionViewCell {

    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    static let height: CGFloat = 180
    
    @IBOutlet weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.layer.borderWidth = 0.5
            newValue.layer.borderColor = AppColor.tint.cgColor
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var emptyLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 3
            newValue.lineBreakMode = .byWordWrapping
            newValue.textColor = AppColor.label.color.withAlphaComponent(0.5)
            newValue.font = .appFont(.regular, size: 16)
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
        
        backgroundColor =  AppColor.background.color
    }
    
    func setupViewConstranint() {
        if isEmpty {
            rightConstraint.constant = 8
        } else {
            rightConstraint.constant = -15
        }
    }
    
    func setup(title: String, emptyText: String) {
        titleLabel.text = title
        emptyLabel.text = emptyText
        setupViewConstranint()
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
        setupViewConstranint()
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
