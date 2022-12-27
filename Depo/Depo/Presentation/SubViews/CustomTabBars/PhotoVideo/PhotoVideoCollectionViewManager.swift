//
//  PhotoVideoCollectionViewManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoVideoCollectionViewManagerDelegate: AnyObject {
    func openAutoSyncSettings()
    func openViewTypeMenu(sender: UIButton)
    func openUploadPhotos()
    func threeDotsButtonTapped(_ button: UIButton?)
}

enum GalleryViewType: CaseIterable {
    case all
    case synced
    case unsynced

    var title: String {
        switch self {
        case .all:
            return TextConstants.galleryFilterAll
        case .synced:
            return TextConstants.galleryFilterSynced
        case .unsynced:
            return TextConstants.galleryFilterUnsynced
        }
    }

    private var actionSheetTitle: String {
        switch self {
        case .all:
            return TextConstants.galleryFilterActionSheetAll
        case .synced:
            return TextConstants.galleryFilterActionSheetSynced
        case .unsynced:
            return TextConstants.galleryFilterActionSheetUnsynced
        }
    }

    static func createAlertActions(handler: @escaping (_ newType: GalleryViewType) -> Void) -> [UIAlertAction] {
        return Self.allCases.map { type in
            UIAlertAction(title: type.actionSheetTitle, style: .default) { _ in
                handler(type)
            }
        }
    }
}

final class PhotoVideoCollectionViewManager {

    private let emptyDataView = EmptyDataView.initFromNib()
    private var moreButton = UIButton()
    
    private weak var collectionView: UICollectionView!
    private weak var delegate: PhotoVideoCollectionViewManagerDelegate?
    let collectionViewLayout = GalleryCollectionViewLayout()
    
    var selectedIndexes: [IndexPath] {
        return collectionView.indexPathsForSelectedItems ?? []
    }
    
    var viewType = GalleryViewType.all
    
    init(collectionView: UICollectionView, delegate: PhotoVideoCollectionViewManagerDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
    }

    func setup() {
        setupCollectionView()
    }
    
    func deselectAll() {
        selectedIndexes.forEach { indexPath in
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    func showEmptyDataViewIfNeeded(isShow: Bool, type: ElementTypes) {
        guard isShow else {
            emptyDataView.removeFromSuperview()
            moreButton.removeFromSuperview()
            return
        }
        
        emptyDataView.configure(viewType: type)
        emptyDataView.delegate = self
        
        moreButton.frame = CGRect(x: collectionView.frame.width - 40, y: 13 , width: 24, height: 24)
        moreButton.setImage(Image.iconThreeDotsHorizontal.image, for: .normal)
        moreButton.addTarget(self, action: #selector(threeDotsButtonTapped(_:)), for: .primaryActionTriggered)
        
        guard emptyDataView.superview == nil else {
            return
        }
        
        collectionView.addSubview(emptyDataView)
        collectionView.addSubview(moreButton)
        
        emptyDataView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyDataView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            emptyDataView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyDataView.widthAnchor.constraint(equalTo: collectionView.widthAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.allowsMultipleSelection = true
        collectionView.register(nibCell: PhotoVideoCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionView.elementKindSectionHeader)
        collectionView.isPrefetchingEnabled = false
    }
    
    @objc private func threeDotsButtonTapped(_ button: UIButton?) {
        delegate?.threeDotsButtonTapped(button)
    }
}

// MARK: - EmptyDataViewDelegate

extension PhotoVideoCollectionViewManager: EmptyDataViewDelegate {
    func didButtonTapped() {
        delegate?.openUploadPhotos()
    }
}
