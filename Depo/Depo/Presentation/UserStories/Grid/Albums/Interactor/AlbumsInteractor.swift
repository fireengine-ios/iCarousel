//
//  AlbumsAlbumsInteractor.swift
//  Depo
//
//  Created by Oleg on 23/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class AlbumsInteractor: BaseFilesGreedInteractor {
    
    private let albumService = PhotosAlbumService()
    var photos: [BaseDataSourceItem]?

    func allItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder) {
        
        //guard let remote =  remoteItems as? AlbumService else{
        //    return
        //}
        
        //remote.allAlbums(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] (albums) in
          //  self?.items(items: albums)
        //}, fail: { })
    }
    
    override func getAllItems(sortBy: SortedRules) {
        debugLog("AlbumsInteractor getAllItems")

        guard let remote = remoteItems as? AlbumService else {
            return
        }
        remote.allAlbums(sortBy: sortBy.sortingRules, sortOrder: sortBy.sortOder, success: { [weak self]  albumbs in
            DispatchQueue.main.async {
                debugLog("AlbumsInteractor getAllItems AlbumService allAlbums success")

                var array = [[BaseDataSourceItem]]()
                array.append(albumbs)
                self?.output.getContentWithSuccess(array: array)
            }
        }, fail: { [weak self] in
            debugLog("AlbumsInteractor getAllItems AlbumService allAlbums fail")

            DispatchQueue.main.async {
                self?.output.asyncOperationFail(errorMessage: TextConstants.errorErrorToGetAlbums)
            }
        })
    }
    
    override func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.AlbumsScreen())
        analyticsManager.logScreen(screen: .albums)
        analyticsManager.trackDimentionsEveryClickGA(screen: .albums)
    }
    
    func onAddPhotosToAlbum(selectedAlbumUUID: String) {
        debugLog("AlbumsInteractor onAddPhotosToAlbum")

        guard let photos = photos as? [Item] else { return }
        
        output.startAsyncOperation()
        let parameters = AddPhotosToAlbum(albumUUID: selectedAlbumUUID, photos: photos)
        
        albumService.addPhotosToAlbum(parameters: parameters, success: { [weak self] in
            debugLog("AlbumsInteractor onAddPhotosToAlbum PhotosAlbumService addPhotosToAlbum success")
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToAlbum(status: .success))
            DispatchQueue.main.async {
                print("success")
                self?.output.asyncOperationSuccess()
                
                if let presenter = self?.output as? AlbumSelectionPresenter {
                    presenter.photoAddedToAlbum()
                }
                ItemOperationManager.default.filesAddedToAlbum()
            }
        }) { [weak self] error in
            debugLog("AlbumsInteractor onAddPhotosToAlbum PhotosAlbumService addPhotosToAlbum error")
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToAlbum(status: .failure))
            DispatchQueue.main.async {
                self?.output.asyncOperationFail(errorMessage: error.description)
            }
        }
    }
    
    override func trackItemsSelected(item: BaseDataSourceItem) {
        if let album = item as? AlbumItem, album.isTBMatik {
            analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.selectAlbum))
        }
    }
}
