//
//  PeopleAlbumSliderInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/2/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class PeopleAlbumSliderInteractor: LBAlbumLikePreviewSliderInteractor {
    let peopleItem: PeopleItem
    let peopleService = PeopleService()
    
    init(peopleItem: PeopleItem) {
        self.peopleItem = peopleItem
        super.init()
    }
    
    override func requestAllItems() {
        guard let id = peopleItem.id else {
            return
        }
        peopleService.getAlbumsForPeopleItemWithID(Int(id), success: { [weak self] (albums) in
            let albumItems = albums.map({ AlbumItem(remote: $0) })
            albumItems.forEach({ (album) in
                self?.dataStorage.addNew(item: SliderItem(withAlbum: album))
            })
            if let currentItems = self?.currentItems {
                self?.output.operationSuccessed(withItems: currentItems)
            }
        }) { [weak self] (error) in
            self?.output.operationFailed()
        }
    }
    
}
