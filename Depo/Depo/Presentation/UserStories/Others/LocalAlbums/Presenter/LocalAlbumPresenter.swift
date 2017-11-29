//
//  LocalAlbumPresenter.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LocalAlbumPresenter: BaseFilesGreedPresenter {
        
    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = ArrayDataSourceForCollectionView()
        interactor.viewIsReady()
        dataSource.displayingType = .list
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.localAlbumCell)
        
        super.viewIsReady(collectionView: collectionView)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
    }
    
    override func uploadData(_ searchText: String! = nil) {
        interactor.getAllItems(sortBy: sortedRule)
    }
    
    override func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 64)
    }
    
    override func getCellSizeForGreed() -> CGSize {
        return CGSize(width: 100, height: 136)
    }
    
    override func reloadData() {
        startAsyncOperation()
        interactor.getAllItems(sortBy: sortedRule)
    }
    
    override func moveBack() {
        router.showBack()
    }
}

