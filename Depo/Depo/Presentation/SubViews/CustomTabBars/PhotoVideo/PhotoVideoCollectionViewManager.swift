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

    private weak var contentSliderTopY: NSLayoutConstraint!
    private weak var contentSliderH: NSLayoutConstraint!

    let scrolliblePopUpView = CardsContainerView()
    private let emptyDataView = EmptyDataView.initFromNib()
    
    private weak var collectionView: UICollectionView!
    private weak var delegate: PhotoVideoCollectionViewManagerDelegate?
    let collectionViewLayout = PhotoVideoCollectionViewLayout()
    
    var selectedIndexes: [IndexPath] {
        return collectionView.indexPathsForSelectedItems ?? []
    }
    
    var viewType = GalleryViewType.all
    
    init(collectionView: UICollectionView, delegate: PhotoVideoCollectionViewManagerDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: scrolliblePopUpView)
    }

    func setup() {
        setupCollectionView()
        setupViewForPopUp()
    }
    
    func setScrolliblePopUpView(isActive: Bool) {
        scrolliblePopUpView.isActive = isActive
        if isActive {
            CardsManager.default.updateAllProgressesInCardsForView(view: scrolliblePopUpView)
        }
    }
    
    func deselectAll() {
        selectedIndexes.forEach { indexPath in
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
    func showEmptyDataViewIfNeeded(isShow: Bool) {
        guard isShow else {
            emptyDataView.removeFromSuperview()
            return
        }
        
        emptyDataView.configure(viewType: viewType)
        emptyDataView.delegate = self
        
        guard emptyDataView.superview == nil else {
            return
        }
        
        collectionView.addSubview(emptyDataView)
        
        emptyDataView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyDataView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
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

    private func setupViewForPopUp() {
        CardsManager.default.addViewForNotification(view: scrolliblePopUpView)
        
        scrolliblePopUpView.delegate = self
        scrolliblePopUpView.isEnable = true
        
        scrolliblePopUpView.addNotPermittedCardViewTypes(types: [.waitingForWiFi, .autoUploadIsOff, .freeAppSpace, .freeAppSpaceLocalWarning, .sharedWithMeUpload])
        
        collectionView.addSubview(scrolliblePopUpView)
        
        scrolliblePopUpView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        contentSliderTopY = scrolliblePopUpView.topAnchor.constraint(equalTo: collectionView.topAnchor)
        contentSliderH = scrolliblePopUpView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            scrolliblePopUpView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            scrolliblePopUpView.widthAnchor.constraint(equalTo: collectionView.widthAnchor),
            contentSliderTopY,
            contentSliderH,
        ])
    }
}


// MARK: - ViewForPopUpDelegate scrolliblePopUpView.delegate
extension PhotoVideoCollectionViewManager: CardsContainerViewDelegate {
    func onUpdateViewForPopUpH(h: CGFloat) {
        contentSliderTopY.constant = -h
        contentSliderH.constant = h
        collectionView.contentInset.top = h
        collectionView?.scrollToTop(animated: true)
    }
}

// MARK: - EmptyDataViewDelegate

extension PhotoVideoCollectionViewManager: EmptyDataViewDelegate {
    func didButtonTapped() {
        delegate?.openUploadPhotos()
    }
}
