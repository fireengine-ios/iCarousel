//
//  PhotoPrintAlbumSelectionViewController.swift
//  Depo
//
//  Created by Ozan Salman on 24.07.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoPrintAlbumSelectionDelegate: AnyObject {
    func onSelectAlbum(_ album: AlbumItem)
}

final class PhotoPrintAlbumSelectionViewController: UIViewController, ErrorPresenter {
    
    private lazy var noFilesView = PhotoSelectionNoFilesView.initFromNib()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        collectionView.backgroundView = noFilesView
        noFilesView.frame = collectionView.bounds
        return collectionView
    }()
    
    private let albumService = AlbumService(requestSize: 100)
    private let dataSource = PhotoPrintAlbumSelectionDataSource()
    
    private let refresher = UIRefreshControl()
    
    private weak var delegate: PhotoPrintAlbumSelectionDelegate?
    
    // MARK: - Life cycle
    
    init(title: String, delegate: PhotoPrintAlbumSelectionDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.title = title
    }
    
    /// will never be called
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        loadAlbums()
        
        noFilesView.noPhotos.image = Image.iconPickNoAlbums.image
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func configure() {
        view.addSubview(collectionView)
        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        
        refresher.tintColor = .clear
        refresher.addTarget(self, action: #selector(loadAlbums), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    // MARK: - Functions
    
    @objc private func loadAlbums() {
        if refresher.isRefreshing {
            refresher.endRefreshing()
        }
        
        noFilesView.text = TextConstants.loading
        collectionView.backgroundView = noFilesView
        
        albumService.allAlbums(sortBy: .date, sortOrder: .desc, success: { [weak self] albums in
            guard let `self` = self else { return }
            
            DispatchQueue.toMain {
                self.dataSource.reload(with: albums)
                
                if albums.isEmpty {
                    self.noFilesView.text = TextConstants.thereAreNoAlbums
                } else {
                    self.collectionView.backgroundView = nil
                }
            }
        }, fail: { [weak self] in
            DispatchQueue.toMain {
                self?.showErrorAlert(message: TextConstants.errorErrorToGetAlbums)
            }
        })
    }
}

extension PhotoPrintAlbumSelectionViewController: PhotoPrintAlbumSelectionDataSourceDelegate {
    func onSelectAlbum(_ album: AlbumItem) {
        delegate?.onSelectAlbum(album)
    }
}

