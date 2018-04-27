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
        log.debug("BaseFilesGreedInteractor reloadItems")
        
        guard isUpdating == false else {
            return
        }
        isUpdating = true
        remoteItems.reloadItems(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] items in
            DispatchQueue.main.async {
                log.debug("BaseFilesGreedInteractor reloadItems RemoteItemsService reloadItems success")
                
                var isArrayPresenter = false
                if let presenter = self?.output as? BaseFilesGreedPresenter {
                    isArrayPresenter = presenter.isArrayDataSource()
                }
                
                self?.isUpdating = false
                if items.count == 0 {
                    self?.output.getContentWithSuccessEnd()
                } else if isArrayPresenter {
                    var array = [[WrapData]]()
                    array.append(items)
                    self?.output.getContentWithSuccess(array: array)
                } else if items.count > 0 {
                    self?.output.getContentWithSuccess(items: items)
                }
            }
            }, fail: { [weak self] in
                log.debug("BaseFilesGreedInteractor reloadItems RemoteItemsService reloadItems fail")

                self?.isUpdating = false
                self?.output.getContentWithFail(errorString: nil)//asyncOperationFail(errorMessage: nil)
            },
               newFieldValue: newFieldValue)
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        log.debug("BaseFilesGreedInteractor nextItems")

        guard isUpdating == false else {
            return
        }
        isUpdating = true
        remoteItems.nextItems(sortBy: sortBy,
                              sortOrder: sortOrder,
                              success: { [weak self] items in
                DispatchQueue.main.async {
                    log.debug("BaseFilesGreedInteractor nextItems RemoteItemsService reloadItems success")

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
                log.debug("BaseFilesGreedInteractor nextItems RemoteItemsService reloadItems fail")

                self?.isUpdating = false
                self?.output.asyncOperationFail(errorMessage: nil)
        }, newFieldValue: newFieldValue)
    }
    
    func canShowNoFilesView() -> Bool {
        return remoteItems is PhotoAndVideoService ||
            remoteItems is MusicService || 
            remoteItems is DocumentService ||
            remoteItems is StoryService ||
            remoteItems is AlbumService ||
            remoteItems is AllFilesService ||
            remoteItems is FavouritesService ||
            remoteItems is PeopleItemsService ||
            remoteItems is ThingsItemsService ||
            remoteItems is PlacesItemsService
    }
    
    func needHideTopBar() -> Bool {
        return !(remoteItems is PhotoAndVideoService)
    }
    
    func textForNoFileTopLabel() -> String {
        if remoteItems is AlbumDetailService {
            return TextConstants.albumEmptyText
        } else if remoteItems is FaceImageDetailService {
            return TextConstants.albumEmptyText
        }
        return TextConstants.folderEmptyText
    }
    
    func textForNoFileLbel() -> String {
        if remoteItems is PhotoAndVideoService {
            return TextConstants.photosVideosViewNoPhotoTitleText
        } else if remoteItems is MusicService {
            return TextConstants.audioViewNoAudioTitleText
        } else if remoteItems is DocumentService {
            return TextConstants.documentsViewNoDocumenetsTitleText
        } else if remoteItems is StoryService {
            return TextConstants.storiesViewNoStoriesTitleText
        } else if remoteItems is AlbumService {
            return TextConstants.albumsViewNoAlbumsTitleText
        } else if remoteItems is AllFilesService {
            return TextConstants.allFilesViewNoFilesTitleText
        } else if remoteItems is FavouritesService {
            return TextConstants.favoritesViewNoFilesTitleText
        }
        
        return ""
    }
    
    func textForNoFileButton() -> String {
        if remoteItems is PhotoAndVideoService {
            return TextConstants.photosVideosViewNoPhotoButtonText
        } else if remoteItems is StoryService {
            return TextConstants.storiesViewNoStoriesButtonText
        } else if remoteItems is AlbumService {
            return TextConstants.albumsViewNoAlbumsButtonText
        } else if remoteItems is AllFilesService {
            return TextConstants.allFilesViewNoFilesButtonText
        } else if remoteItems is FavouritesService {
            return TextConstants.favoritesViewNoFilesButtonText
        }
    
        return ""
    }
    
    func imageForNoFileImageView() -> UIImage {
        if remoteItems is PhotoAndVideoService {
            return UIImage(named: "ImageNoPhotos")!
        } else if remoteItems is MusicService {
            return UIImage(named: "ImageNoMusics")!
        } else if remoteItems is DocumentService {
            return UIImage(named: "ImageNoDocuments")!
        } else if remoteItems is StoryService {
            return UIImage(named: "ImageNoStories")!
        } else if remoteItems is AlbumService {
            return UIImage(named: "ImageNoAlbums")!
        } else if remoteItems is AllFilesService {
            return UIImage(named: "ImageNoAllFiles")!
        } else if remoteItems is FavouritesService {
            return UIImage(named: "ImageNoFavorites")!
        }
        return UIImage()
    }
    
    func getRemoteItemsService() -> RemoteItemsService {
        return remoteItems
    }
    
    func getFolder() -> Item? {
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
        get { return originalFilters }
        set { originalFilters = newValue}
    }
    
    func getAllItems(sortBy: SortedRules) {
        
    }
    
    var requestPageNum: Int {
        return remoteItems.currentPage
    }
}
