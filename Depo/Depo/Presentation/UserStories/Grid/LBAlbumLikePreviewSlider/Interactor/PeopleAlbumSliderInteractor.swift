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
        peopleService.getAlbumsForPeopleItemWithID(Int(id), success: { [weak self] albums in
            self?.currentItems = albums.flatMap { SliderItem(asFirAlbum: AlbumItem(remote: $0)) }
            
            if let currentItems = self?.currentItems {
                DispatchQueue.main.async {
                    self?.output?.operationSuccessed(withItems: currentItems)
                }
            }
            
            }, fail: { [weak self] error in
                self?.output?.operationFailed()
        })
    }
    
    override func newStoryCreated() { }
    
    override func finishUploadFiles() { }
    
}
