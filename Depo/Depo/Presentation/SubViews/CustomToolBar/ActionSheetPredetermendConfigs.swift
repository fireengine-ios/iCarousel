//
//  ActionSheetPredetermendConfigs.swift
//  Depo
//
//  Created by Aleksandr on 8/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum ActionSheetPredetermendConfigs {
    static let photoVideoDetailActions: [ElementTypes] = [
        .info, .addToFavorites, .removeFromFavorites, .addToAlbum, .smash, .hide
    ]
    static let audioDetailActions: [ElementTypes] = [.info, .addToAlbum]
    static let documetsDetailActions: [ElementTypes] = []
    static let hiddenDetailActions: [ElementTypes] = []
    static let trashedDetailActions: [ElementTypes] = [.info]
}
