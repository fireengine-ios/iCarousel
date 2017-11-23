//
//  ActionSheetPredetermendConfigs.swift
//  Depo
//
//  Created by Aleksandr on 8/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class ActionSheetPredetermendConfigs {
    
    static let homeFileSelectedAll: [ElementTypes] = [.copy, .addToFavorites]

    static let allFilesListOption: [ElementTypes] = [.select, .selectAll]
    static let albumPhotosSelectOptions: [ElementTypes] = [.removeFromAlbum, .createStory, .addToFavorites, .makeAlbumCover]
    static let albumOpenedActions: [ElementTypes] = [.albumDetails, .shareAlbum, .select, .selectAll]
    static let albumsActions: [ElementTypes] = [.select, .selectAll]
    static let albumSelectOptions: [ElementTypes] = [.copy, .albumDetails, .addToFavorites, .delete]
    static let photosActions: [ElementTypes] = [.select, .selectAll]
    static let photosSelectActionsUnsync: [ElementTypes] = [.createStory, .copy, .addToFavorites, .addToAlbum, .makeAlbumCover, .backUp]
    static let photosSelectActionsSync: [ElementTypes] = [.createStory, .copy, .addToFavorites, .addToAlbum, .makeAlbumCover, .download]
    static let musicActions: [ElementTypes] = [.select, .selectAll]
    static let musicListSelectedActions: [ElementTypes] = [.addToPlaylist, .addToFavorites]
    static let photoVideoDetailActions: [ElementTypes] = [.info, .addToAlbum]
    
}
