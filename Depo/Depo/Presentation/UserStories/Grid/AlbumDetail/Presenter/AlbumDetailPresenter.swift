//
//  AlbumDetailAlbumDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumDetailPresenter: BaseFilesGreedPresenter {
    
    weak var moduleOutput: AlbumDetailModuleOutput?
    
    func operationStarted(type: ElementTypes){
        
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        let router = self.router as! AlbumDetailRouter
        switch type {
        case .removeFromAlbum:
            onReloadData()
        case .completelyDeleteAlbums:
            router.back()
            moduleOutput?.onAlbumDeleted()
            break
        case .removeAlbum:
            router.back()
            moduleOutput?.onAlbumRemoved()
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
    
}
