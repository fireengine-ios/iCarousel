//
//  UploadGalleryPickerController.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
protocol UploadGalleryAssetPickerControllerDelegate: class {
    func didSelect(assets: [PHAsset])
}


final class UploadGalleryAssetPickerController: BaseViewController, NibInit {
    
    @IBOutlet private weak var collectionView: QuickSelectCollectionView!
    
    private let selectedAssetsLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
    private lazy var collectionManager = UploadGalleryAssetPickerCollectionManager(collection: collectionView, selectionDelegate: self)
    private var albumId: String?
    
    weak var delegate: UploadGalleryAssetPickerControllerDelegate?
    
    
    //MARK: Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = String(format: TextConstants.itemsSelectedTitle, 0)
        setupNavBar()
        setupTopRefresher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTitle()
        fullReload()
    }
    
    
    //MARK: Private
    
    private func setupNavBar() {
        setNavigationBarStyle(.white)

        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setNavigationRightBarButton(style: .byDefault,
                                    title: TextConstants.uploadSelectButtonTitle,
                                    target: self, action: #selector(upload))
    }
    
    @objc private func upload() {
        let selectedIds = Array(UploadPickerAssetSelectionHelper.shared.getAll())
        let assets = AssetProvider.shared.getAssets(with: selectedIds)
        delegate?.didSelect(assets: assets)
        UploadPickerAssetSelectionHelper.shared.clear()
    }
    
    private func updateTitle() {
        let itemsSelected = UploadPickerAssetSelectionHelper.shared.getAll().count
        title = String(format: TextConstants.itemsSelectedTitle, itemsSelected)
    }
    
    private func setupTopRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.separator.color
        refresher.addTarget(self, action: #selector(fullReload), for: .valueChanged)
        collectionView?.refreshControl = refresher
    }
    
    @objc private func fullReload() {
        guard let albumId = albumId else {
            collectionManager.reload(with: [])
            return
        }
        
        let assets = AssetProvider.shared.getAllAssets(for: albumId)
        collectionManager.reload(with: assets)
    }
    
}


extension UploadGalleryAssetPickerController {
    static func with(albumId: String) -> UploadGalleryAssetPickerController {
        let controller = UploadGalleryAssetPickerController.initFromNib()
        controller.albumId = albumId
        return controller
    }
}


extension UploadGalleryAssetPickerController: UploadGalleryAssetPickerCollectionManagerDelegate {
    func didChangeSelection() {
        updateTitle()
    }
}
