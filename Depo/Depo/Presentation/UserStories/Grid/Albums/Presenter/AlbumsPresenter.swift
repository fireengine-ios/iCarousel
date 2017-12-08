//
//  AlbumsAlbumsPresenter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsPresenter: BaseFilesGreedPresenter {

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
//        if (Device.isIpad){
            return CGSize(width: 100, height: 136)
//        }
//        
//        let w = view.getCollectionViewWidth()
//        let cellW: CGFloat = (w - NumericConstants.iPhoneGreedInset * 2 - NumericConstants.iPhoneGreedHorizontalSpace * NumericConstants.numerCellInLineOnIphone)/NumericConstants.numerCellInLineOnIphone
//        return CGSize(width: cellW, height: cellW)
    }
    
    override func sortedPushed(with rule: SortedRules){
        //sortedRule = rule
        sortedRule = rule
        interactor.getAllItems(sortBy: rule)
        view.changeSortingRepresentation(sortType: rule)
        
        
//        dataSource.fetchService.performFetch(sortingRules: sortedRule,
//                                             filtes: filters)
//        dataSource.reloadData()
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

    //  override func getNextItems() { //TODO: implement pagination
//        interactor.nextItems(nil, sortBy: .albumName,
//                         sortOrder: .asc)
//
//    }
}

extension AlbumsPresenter: AlbumDetailModuleOutput {
    
    func onAlbumRemoved() {
        reloadData()
    }
    
    func onAlbumDeleted() {
        reloadData()
    }
}
