//
//  AlbumDetailAlbumDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailPresenter: BaseFilesGreedPresenter {
    
    weak var albumDetailModuleOutput: AlbumDetailModuleOutput?
    
    func operationStarted(type: ElementTypes){
        
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        guard let router = self.router as? AlbumDetailRouter else { return }
        switch type {
        case .removeFromAlbum:
            onReloadData()
        case .completelyDeleteAlbums:
            router.back()
            albumDetailModuleOutput?.onAlbumDeleted()
        case .removeAlbum:
            router.back()
            albumDetailModuleOutput?.onAlbumRemoved()
        default:
            return
        }
    }
    
    override var selectedItems: [BaseDataSourceItem] {
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
        //        .print
        guard var barConfig = interactor.bottomBarConfig
//            ,
//            let array = dataSource.getSelectedItems() as? [Item]
            else {
                return
        }
        let allSelectedItemsTypes = selectedItems.map{return $0.fileType}
        if allSelectedItemsTypes.contains(.image) {
            let actionTypes = barConfig.elementsConfig + [.print]
            
            barConfig = EditingBarConfig(elementsConfig: actionTypes,
                                         style: barConfig.style,
                                         tintColor: barConfig.tintColor)
        }
        
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
}
