//
//  BaseFilesGreedInteractor.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BaseFilesGreedInteractor: BaseFilesGreedInteractorInput {

    weak var output: BaseFilesGreedInteractorOutput!

    var remoteItems: RemoteItemsService
    
    var folder: Item?
    
    var originalFilters: [GeneralFilesFiltrationType]?
    
    var bottomBarOriginalConfig: EditingBarConfig?
    
    var alertSheetConfig: AlertFilesActionsSheetInitialConfig?
    
    init(remoteItems: RemoteItemsService) {
        self.remoteItems = remoteItems
    }
    
    func viewIsReady() {
        
    }
    
    func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder) {
        
        remoteItems.reloadItems(sortBy: sortBy, sortOrder: sortOrder, success: nil, fail: nil)
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder ) {
        
        remoteItems.nextItems(sortBy: sortBy,
                              sortOrder: sortOrder,
                              success:
            {
                [weak self] item in
                DispatchQueue.main.async { [weak self] in
                    if let out = self?.output as? CreateStorySelectionInteractorOutput {
                        var array = [[WrapData]]()
                        array.append(item)
                        out.getContentWithSuccess(array: array)
                    }else{
                        self?.output.getContentWithSuccess()
                    }
                }
            }, fail: { })
    }

    func needShowNoFileView()-> Bool{
        if ((remoteItems is PhotoAndVideoService) ||
            (remoteItems is MusicService)) {
            return true
        }
        return false
    }
    
    func textForNoFileLbel() -> String{
        if (remoteItems is PhotoAndVideoService){
            return TextConstants.photosVideosViewNoPhotoTitleText
        }
        return TextConstants.audioViewNoAudioTitleText
    }
    
    func textForNoFileButton() -> String{
        if (remoteItems is PhotoAndVideoService){
            return TextConstants.photosVideosViewNoPhotoButtonText
        }
        return TextConstants.audioViewNoAudioButtonText
    }
    
    func imageForNoFileImageView() -> UIImage{
        if (remoteItems is PhotoAndVideoService){
            return UIImage(named: "ImageNoPhotos")!
        }
        return UIImage(named: "ImageNoMusics")!
    }
    
    func getRemoteItemsService() -> RemoteItemsService{
        return remoteItems
    }
    
    func getFolder() -> Item?{
        return folder
    }
    
    var bottomBarConfig: EditingBarConfig? {
        set {
            bottomBarOriginalConfig = newValue
        }
        get {
            return bottomBarOriginalConfig
        }
    }
    
    var alerSheetMoreActionsConfig: AlertFilesActionsSheetInitialConfig? {
        get {
            return alertSheetConfig
        }
    }
    
    var originalFilesTypeFilter: [GeneralFilesFiltrationType]? {
        return originalFilters
    }
}
