//
//  AlbumDetailAlbumDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailPresenter: BaseFilesGreedPresenter {
    
    weak var albumDetailModuleOutput: AlbumDetailModuleOutput?
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    func operationStarted(type: ElementTypes) {
        
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        debugLog("AlbumDetailPresenter operationFinished")

        guard let router = self.router as? AlbumDetailRouter else { return }
        switch type {
        case .removeFromAlbum:
            debugLog("AlbumDetailPresenter operationFinished type == removeFromAlbum")

            //onReloadData()
        case .completelyMoveToTrash:
            debugLog("AlbumDetailPresenter operationFinished type == completelyMoveToTrash")

            router.back()
            albumDetailModuleOutput?.onAlbumDeleted()
        case .removeAlbum:
            debugLog("AlbumDetailPresenter operationFinished type == removeAlbum")

            router.back()
            albumDetailModuleOutput?.onAlbumRemoved()
        default:
            return
        }
    }
    
    override func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        debugLog("AlbumDetailPresenter operationFinished")
        super.getSelectedItems { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            if selectedItems.count > 0 {
                selectedItemsCallback(selectedItems)
            } else if let interactor = self.interactor as? AlbumDetailInteractor, let album = interactor.album {
                selectedItemsCallback([album])
            } else {
                selectedItemsCallback([])
            }
        }
    }
    
    override func setupNewBottomBarConfig() {
        guard var barConfig = interactor.bottomBarConfig else {
                return
        }
        getSelectedItems { [weak self] selectedItems in
            let allSelectedItemsTypes = selectedItems.map { $0.fileType }
            if allSelectedItemsTypes.contains(.image) {
                let actionTypes = barConfig.elementsConfig
                
                barConfig = EditingBarConfig(elementsConfig: actionTypes,
                                             style: barConfig.style,
                                             tintColor: barConfig.tintColor)
            }
            
            self?.bottomBarPresenter?.setupTabBarWith(config: barConfig)
        }
    }
    
    override func updateCoverPhotoIfNeeded() {
        if let interactor = interactor as? AlbumDetailInteractor {
            interactor.updateCoverPhotoIfNeeded()
        }
    }
    
    override func viewAppearanceChanged(asGrid: Bool) {
        debugLog("AlbumDetailPresenter viewAppearanceChanged")
        
        if  asGrid {
            debugLog("AlbumDetailPresenter viewAppearanceChanged Grid")
            
            dataSource.updateDisplayngType(type: .greed)
            type = .List
        } else {
            debugLog("AlbumDetailPresenter viewAppearanceChanged List")
            
            dataSource.updateDisplayngType(type: .list)
            type = .Grid
        }
    }
    
    override func sortedPushed(with rule: SortedRules) {
        debugLog("AlbumDetailPresenter sortedPushed")
        
        sortedRule = rule
        view.changeSortingRepresentation(sortType: rule)
        dataSource.currentSortType = rule
        (rule == .sizeAZ || rule == .sizeZA) ? (dataSource.isHeaderless = true) : (dataSource.isHeaderless = false)
        
        reloadData()
    }
    
    override func updateThreeDotsButton() {
        view?.setThreeDotsMenu(active: true)
    }
    
    override func didDelete(items: [BaseDataSourceItem]) {
        super.didDelete(items: items)
        
        if let album = (interactor as? AlbumDetailInteractor)?.album, album.isTBMatik {
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.deletePhoto))
        }
    }
}
