//
//  HiddenAlbumDetailPresenter.swift
//  Depo
//
//  Created by Alex on 12/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

final class HiddenAlbumDetailPresenter: AlbumDetailPresenter {
    
}

//MARK: - ItemOperationManagerViewProtocol related
extension HiddenAlbumDetailPresenter {
    
    func moveToTrash(items: [Item]) {
        view.disableRefresh()
    }
    
    func didUnhide(items: [WrapData]) {
        view.disableRefresh()
        dataSource.deleteItems(items: items)
    }
    
    func didUnhide(albums: [AlbumItem]) {
        guard let router = self.router as? AlbumDetailRouter else {
            return
        }
        
        router.back()
    }
    
}
