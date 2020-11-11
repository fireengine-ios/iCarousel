//
//  PrivateShareSharedFilesCollectionManager.swift
//  Depo
//
//  Created by Konstantin Studilin on 11.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import UIKit


final class PrivateShareSharedFilesCollectionManager: NSObject {
    
    static func with(collection: UICollectionView, fileInfoManager: PrivateShareFileInfoManager) -> PrivateShareSharedFilesCollectionManager {
        let manager = PrivateShareSharedFilesCollectionManager()
        manager.collectionView = collection
        manager.fileInfoManager = fileInfoManager
        return manager
    }
    
    private weak var collectionView: UICollectionView?
    
    private var fileInfoManager: PrivateShareFileInfoManager?
    
    
    //MARK: -
    
    private override init() { }
    
    //MARK: - Public
    
    func setup() {
        setupCollection()
        setupRefresher()
        reload()
    }
    
    //MARK: - Private
    
    private func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    private func setupCollection() {
        collectionView?.register(nibCell: BasicCollectionMultiFileCell.self)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    private func setupRefresher() {
        let refresher = UIRefreshControl()
        refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(reload), for: .valueChanged)
        collectionView?.refreshControl = refresher
        
    }
    
    @objc
    private func reload() {
        fileInfoManager?.reload { [weak self] _ in
            self?.reloadCollection()
        }
    }
}


extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fileInfoManager?.loadedItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: BasicCollectionMultiFileCell.self, for: indexPath)
    }
    
    
}


extension PrivateShareSharedFilesCollectionManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.contentSize.width
        let height = CGFloat(64.0)
        return CGSize(width: width, height: height)
    }
}
