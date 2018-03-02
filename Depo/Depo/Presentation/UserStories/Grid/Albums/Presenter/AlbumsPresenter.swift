//
//  AlbumsAlbumsPresenter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsPresenter: BaseFilesGreedPresenter {

    override func viewIsReady(collectionView: UICollectionView) {
        if (interactor.remoteItems is AlbumService) {
            dataSource = ArrayDataSourceForCollectionView()
        } else {
            dataSource = StoriesDataSourceForCollectionView()
        }
        interactor.viewIsReady()
        sortedRule = .timeUp
        dataSource.setPreferedCellReUseID(reUseID: nil)
        
        super.viewIsReady(collectionView: collectionView)
        
        let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }

    override func uploadData(_ searchText: String! = nil) {
        log.debug("AlbumsPresenter uploadData")

        interactor.getAllItems(sortBy: sortedRule)
    }
    
    override func getCellSizeForList() -> CGSize {
        if (interactor.remoteItems is AlbumService) {
            return CGSize(width: view.getCollectionViewWidth(), height: NumericConstants.albumCellListHeight)
        }
        return super.getCellSizeForList()
    }
    
    override func getCellSizeForGreed() -> CGSize {
        return CGSize(width: 100, height: 136)
    }
    
    override func sortedPushed(with rule: SortedRules){
        log.debug("AlbumsPresenter sortedPushed")
        
        sortedRule = rule
        interactor.getAllItems(sortBy: rule)
        view.changeSortingRepresentation(sortType: rule)
    }
    
    override func reloadData() {
        log.debug("AlbumsPresenter reloadData")

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
        case .LettersAZ:
            sortRule = .lettersAZ
        case .LettersZA:
            sortRule = .lettersZA
        case .TimeNewOld:
            sortRule = .timeUp
        case .TimeOldNew:
            sortRule = .timeDown
        case .Largest:
            sortRule = .sizeAZ
        case .Smallest:
            sortRule = .sizeZA
        case .metaDataTimeNewOld:
            sortRule = .metaDataTimeUp
        case .metaDataTimeOldNew:
            sortRule = .metaDataTimeDown
        default:
            sortRule = .timeUp
        }
        sortedPushed(with: sortRule)
    }
    
    override func onStartCreatingPhotoAndVideos() {
        log.debug("AlbumsPresenter onStartCreatingPhotoAndVideos")
        
        if let router = router as? AlbumsRouter {
            if interactor is AlbumsInteractor {
                router.onCreateAlbum()
            } else if interactor is StoriesInteractor {
                router.onCreateStory()
            }
        }
    }
}

extension AlbumsPresenter: AlbumDetailModuleOutput {
    
    func onAlbumRemoved() {
        reloadData()
    }
    
    func onAlbumDeleted() {
        reloadData()
    }
}
