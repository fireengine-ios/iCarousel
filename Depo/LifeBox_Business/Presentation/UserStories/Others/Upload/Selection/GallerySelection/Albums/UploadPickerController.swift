//
//  UploadPickerController.swift
//  Depo
//
//  Created by Konstantin Studilin on 30.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol UploadPickerControllerDelegate: class {
    func uploadPicker(_ controller: UploadPickerController, didSelect assets: [PHAsset])
}


final class UploadPickerController: BaseViewController, NibInit {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private lazy var collectionManager = UploadPickerAlbumCollectionManager(collection: collectionView, delegate: self)
    
    weak var delegate: UploadPickerControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UploadPickerAssetSelectionHelper.shared.clear()

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
        navigationController?.navigationBar.topItem?.backBarButtonItem = nil
        
        setupCustomButtonAsNavigationBackButton(style: .white, asLeftButton: false, title: "", target: nil, image: CustomBackButtonType.cross.image, action: nil)
    }
    
    private func setupTopRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.separator
        refresher.addTarget(self, action: #selector(fullReload), for: .valueChanged)
        collectionView?.refreshControl = refresher
    }
    
    @objc private func fullReload() {
        AssetProvider.shared.getAlbumsWithItems { [weak self] albums in
            self?.collectionManager.reload(with: albums)
        }
    }
        
}


extension UploadPickerController: UploadPickerAlbumCollectionManagerDelegate {
    func didSelectAlbum(with albumId: String) {
        let controller = UploadGalleryAssetPickerController.with(albumId: albumId)
        controller.delegate = self
        RouterVC().pushViewController(viewController: controller, animated: true)
    }
}


extension UploadPickerController: UploadGalleryAssetPickerControllerDelegate {
    func didSelect(assets: [PHAsset]) {
        delegate?.uploadPicker(self, didSelect: assets)
    }
}
