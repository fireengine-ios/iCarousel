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
        sortedRule = .timeUp
        dataSource.displayingType = .list
        dataSource.setPreferedCellReUseID(reUseID: nil)
        
        super.viewIsReady(collectionView: collectionView)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
    }
    
    override func uploadData(_ searchText: String! = nil) {
        interactor.getAllItems(sortBy: sortedRule)
    }
    
    override func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: NumericConstants.albumCellListHeight)
    }
    
    override func getCellSizeForGreed() -> CGSize {
        return CGSize(width: 100, height: 136)
    }
    
    override func sortedPushed(with rule: SortedRules){
        sortedRule = rule
        interactor.getAllItems(sortBy: rule)
        view.changeSortingRepresentation(sortType: rule)
    }
    
    override func reloadData() {
        startAsyncOperation()
        interactor.getAllItems(sortBy: sortedRule)
    }
    
    override func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType) {
        
        var sortRule: SortedRules
        switch rule {
        case .AlphaBetricAZ:
            sortRule = .albumlettersAZ
        case .AlphaBetricZA:
            sortRule = .albumlettersZA
        case .TimeNewOld:
            sortRule = .timeUp
        case .TimeOldNew:
            sortRule = .timeDown
        case .Largest:
            sortRule = .sizeAZ
        case .Smallest:
            sortRule = .sizeZA
        default:
            sortRule = .timeUp
        }
        sortedPushed(with: sortRule)
    }
    
}

