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
    
    var isUpdating: Bool = false
    
    init(remoteItems: RemoteItemsService) {
        self.remoteItems = remoteItems
    }
    
    var requestPageSize: Int {
        return remoteItems.requestSize
    }
    
    func viewIsReady() {
        
    }
    
    func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        guard isUpdating == false else {
            return
        }
        isUpdating = true
        remoteItems.reloadItems(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] items in
            DispatchQueue.main.async {
                self?.isUpdating = false
                if items.count == 0 {
                    self?.output.getContentWithSuccessEnd()
                } else if let out = self?.output as? CreateStorySelectionInteractorOutput {
                    var array = [[WrapData]]()
                    array.append(items)
                    out.getContentWithSuccess(array: array)
                } else if items.count > 0 {
                    self?.output.getContentWithSuccess(items: items)
                }
            }
            }, fail: { [weak self] in
                self?.isUpdating = false
                self?.output.getContentWithFail(errorString: nil)//asyncOperationFail(errorMessage: nil)
            },
               newFieldValue: newFieldValue)
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        guard isUpdating == false else {
            return
        }
        isUpdating = true
        remoteItems.nextItems(sortBy: sortBy,
                              sortOrder: sortOrder,
                              success:
            { [weak self] items in
                DispatchQueue.main.async {
                    self?.isUpdating = false
                    if items.count == 0 {
                        self?.output.getContentWithSuccessEnd()
                    }
                    else if let out = self?.output as? CreateStorySelectionInteractorOutput {
                        var array = [[WrapData]]()
                        array.append(items)
                        out.getContentWithSuccess(array: array)
                    } else if items.count > 0 {
                        self?.output.getContentWithSuccess(items: items)
                    }
                }
            }, fail: { [weak self] in
                self?.isUpdating = false
                self?.output.asyncOperationFail(errorMessage: nil)
        }, newFieldValue: newFieldValue)
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
    
    func getAllItems(sortBy: SortedRules) {
        
    }
}
