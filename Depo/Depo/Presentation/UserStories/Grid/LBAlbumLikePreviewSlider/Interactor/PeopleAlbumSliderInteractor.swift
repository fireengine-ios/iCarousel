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
        
    }
    
}
