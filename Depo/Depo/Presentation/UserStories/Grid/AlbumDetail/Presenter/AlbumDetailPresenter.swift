//
//  AlbumDetailAlbumDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailPresenter: BaseFilesGreedPresenter {
    
    weak var albumDetailModuleOutput: AlbumDetailModuleOutput?
    
    func operationStarted(type: ElementTypes) {
        
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        log.debug("AlbumDetailPresenter operationFinished")

        guard let router = self.router as? AlbumDetailRouter else { return }
        switch type {
        case .removeFromAlbum:
            log.debug("AlbumDetailPresenter operationFinished type == removeFromAlbum")

            //onReloadData()
        case .completelyDeleteAlbums:
            log.debug("AlbumDetailPresenter operationFinished type == completelyDeleteAlbums")

            router.back()
            albumDetailModuleOutput?.onAlbumDeleted()
        case .removeAlbum:
            log.debug("AlbumDetailPresenter operationFinished type == removeAlbum")

            router.back()
            albumDetailModuleOutput?.onAlbumRemoved()
        default:
            return
        }
    }
    
    override var selectedItems: [BaseDataSourceItem] {
        log.debug("AlbumDetailPresenter operationFinished")

        let selectedItems = super.selectedItems
        if selectedItems.count > 0 {
            return selectedItems
        } else if let interactor = interactor as? AlbumDetailInteractor, let album = interactor.album {
            return [album]
        } else {
            return []
        }
    }
    
    override func setupNewBottomBarConfig() {
        guard var barConfig = interactor.bottomBarConfig else {
                return
        }
        let allSelectedItemsTypes = selectedItems.map { $0.fileType }
        if allSelectedItemsTypes.contains(.image) {
            let actionTypes = barConfig.elementsConfig
            
            barConfig = EditingBarConfig(elementsConfig: actionTypes,
                                         style: barConfig.style,
                                         tintColor: barConfig.tintColor)
        }
        
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
    
    override func updateCoverPhotoIfNeeded() {
        if let interactor = interactor as? AlbumDetailInteractor {
            interactor.updateCoverPhotoIfNeeded()
        }
    }
    
    override func viewAppearanceChanged(asGrid: Bool) {
        log.debug("AlbumDetailPresenter viewAppearanceChanged")
        
        if  asGrid {
            log.debug("AlbumDetailPresenter viewAppearanceChanged Grid")
            
            dataSource.updateDisplayngType(type: .greed)
            type = .List
        } else {
            log.debug("AlbumDetailPresenter viewAppearanceChanged List")
            
            dataSource.updateDisplayngType(type: .list)
            type = .Grid
        }
    }
    
    override func sortedPushed(with rule: SortedRules) {
        log.debug("AlbumDetailPresenter sortedPushed")
        
        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
        dataSource.currentSortType = rule
        (rule == .sizeAZ || rule == .sizeZA) ? (dataSource.isHeaderless = true) : (dataSource.isHeaderless = false)
        
        reloadData()
    }
}
