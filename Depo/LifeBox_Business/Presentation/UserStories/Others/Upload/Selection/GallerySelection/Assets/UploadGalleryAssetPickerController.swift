//
//  UploadGalleryPickerController.swift
//  Depo
//
//  Created by Konstantin Studilin on 29.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol UploadGalleryAssetPickerControllerDelegate: class {
    
}

final class UploadGalleryAssetPickerController: BaseViewController, NibInit {
    
    @IBOutlet private weak var collectionView: QuickSelectCollectionView!

    private let selectedPhotosLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
    private lazy var collectionManager = UploadGalleryAssetPickerCollectionManager(collection: collectionView)
    private var albumId: String?
    
    weak var delegate: UploadGalleryAssetPickerControllerDelegate?
    
    
    //MARK: Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupTopRefresher()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fullReload()
    }
    
    //MARK: Private
    
    private func setupNavBar() {
        setNavigationBarStyle(.white)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func setupTopRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.separator
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
