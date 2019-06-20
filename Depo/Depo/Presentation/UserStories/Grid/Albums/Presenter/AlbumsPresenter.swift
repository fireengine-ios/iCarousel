//
//  AlbumsAlbumsPresenter.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsPresenter: BaseFilesGreedPresenter {
    
    weak var sliderModuleOutput: LBAlbumLikePreviewSliderModuleInput?

    override func viewIsReady(collectionView: UICollectionView) {
        if (interactor.remoteItems is AlbumService) {
            dataSource = AlbumsDataSourceForCollectionView()
            dataSource.originalFilters = interactor.originalFilesTypeFilter
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
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        sliderModuleOutput?.reload(types: [.story, .albums])
    }

    override func uploadData(_ searchText: String! = nil) {
        debugLog("AlbumsPresenter uploadData")

        interactor.getAllItems(sortBy: sortedRule)
    }
    
    override func getCellSizeForList() -> CGSize {
        if (interactor.remoteItems is AlbumService) {
            return CGSize(width: view.getCollectionViewWidth(), height: NumericConstants.albumCellListHeight)
        }
        return super.getCellSizeForList()
    }
    
    override func getCellSizeForGreed() -> CGSize {
        if dataSource is AlbumsDataSourceForCollectionView {
            let sizeCell: CGFloat = (UIScreen.main.bounds.width - NumericConstants.amountInsetForAlbum) / 4

            return CGSize(width: sizeCell, height: sizeCell + NumericConstants.heightTextAlbumCell)
        } else {
            let sizeCell: CGFloat = (UIScreen.main.bounds.width - NumericConstants.amountInsetForStoryAlbum) / 4

            return CGSize(width: sizeCell, height: sizeCell)
        }
    }
    
    override func sortedPushed(with rule: SortedRules) {
        debugLog("AlbumsPresenter sortedPushed")
        
        sortedRule = rule
        interactor.getAllItems(sortBy: rule)
        view.changeSortingRepresentation(sortType: rule)
    }
    
    override func reloadData() {
        debugLog("BaseFilesGreedPresenter reloadData")
        debugPrint("BaseFilesGreedPresenter reloadData")
        
        dataSource.dropData()
        dataSource.currentSortType = sortedRule
        dataSource.reloadData()
        startAsyncOperation()
        dataSource.isPaginationDidEnd = false
        interactor.getAllItems(sortBy: sortedRule)
        view?.stopRefresher()
    }
    
    override func sortedPushedTopBar(with rule: MoreActionsConfig.SortRullesType) {
        
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
        debugLog("AlbumsPresenter onStartCreatingPhotoAndVideos")
        
        if let router = router as? AlbumsRouter {
            if let interactor = interactor as? AlbumsInteractor {
                router.onCreateAlbum(moduleOutput: interactor.photos?.isEmpty == true ? nil : self)
            } else if interactor is StoriesInteractor {
                router.onCreateStory()
            }
        }
    }
}

extension AlbumsPresenter: SelectNameModuleOutput {
    func didCreateAlbum(item: AlbumItem) {
        if let interact = interactor as? AlbumsInteractor {
            if item.readOnly == true {
                UIApplication.showErrorAlert(message: TextConstants.uploadVideoToReadOnlyAlbumError)
            } else {
                interact.onAddPhotosToAlbum(selectedAlbumUUID: item.uuid)
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
