//
//  PeopleCollectionViewCell.swift
//  Depo
//
//  Created by Raman Harhun on 5/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PeopleSliderCellDelegate: class {
    func didSelect(item: PeopleOnPhotoItemResponse)
    func needLoadNextPeoplePage()
    func onStartSelection()
}

final class PeopleSliderCell: UICollectionViewCell {

    static let height: CGFloat = 130
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    weak var delegate: PeopleSliderCellDelegate?
    
    private lazy var dataSource = PeopleSliderDataSource(collectionView: collectionView, delegate: self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    func removeItems(_ items: [PeopleOnPhotoItemResponse], completion: VoidHandler? = nil) {
//        dataSource.removeItems(items) { [weak self] in
//            completion?()
//        }
//    }
    func appendItems(_ newItems: [PeopleOnPhotoItemResponse]) {
        dataSource.appendItems(newItems)
    }
    
    func reset() {
        dataSource.reset()
    }
    
    func finishLoadAlbums() {
        dataSource.isPaginationDidEnd = true
    }
    
}

extension PeopleSliderCell: PeopleSliderDataSourceDelegate {
    func didChangeSelectionCount(_ count: Int) {
        
    }
    
    
    func didSelect(item: PeopleOnPhotoItemResponse) {
        delegate?.didSelect(item: item)
    }
    
    func needLoadNextPage() {
        delegate?.needLoadNextPeoplePage()
    }
    
    func onStartSelection() {
        delegate?.onStartSelection()
    }
}
