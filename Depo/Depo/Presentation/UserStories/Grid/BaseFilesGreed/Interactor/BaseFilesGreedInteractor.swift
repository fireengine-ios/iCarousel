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
    
    let analyticsManager: AnalyticsService = factory.resolve()
    
    private var getNextPageRetryCounter: Int = 0
    
    private let numberOfRetries: Int = 3
    
    init(remoteItems: RemoteItemsService) {
        self.remoteItems = remoteItems
    }
    
    var requestPageSize: Int {
        return remoteItems.requestSize
    }
    
    func viewIsReady() {
        
    }
    
    func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("BaseFilesGreedInteractor reloadItems")
        
        guard isUpdating == false else {
            return
        }
        isUpdating = true
        getNextPageRetryCounter += 1
        remoteItems.reloadItems(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] items in
            self?.getNextPageRetryCounter = 0
            DispatchQueue.main.async {
                debugLog("BaseFilesGreedInteractor reloadItems RemoteItemsService reloadItems success")
                
                var isArrayPresenter = false
                if let presenter = self?.output as? BaseFilesGreedPresenter {
                    isArrayPresenter = presenter.isArrayDataSource()
                }
                
                self?.isUpdating = false
                guard let output = self?.output else { return }
                if items.count == 0 {
                    output.getContentWithSuccessEnd()
                } else if isArrayPresenter {
                    var array = [[WrapData]]()
                    array.append(items)
                    output.getContentWithSuccess(array: array)
                } else if items.count > 0 {
                    output.getContentWithSuccess(items: items)
                }
            }
            }, fail: { [weak self] in
                debugLog("BaseFilesGreedInteractor reloadItems RemoteItemsService reloadItems fail")
                guard let `self` = self, let output = self.output else {
                    return
                }
                if self.getNextPageRetryCounter >= self.numberOfRetries {
                    self.getNextPageRetryCounter = 0
                    self.isUpdating = false
                    /// TODO: Add receiving error with text
                    if self.needShowServerError() {
                        output.getContentWithFail(errorString: TextConstants.errorServerUnderMaintenance)
                    } else {
                        output.getContentWithFail(errorString: nil)
                    }
                } else {
                    self.isUpdating = false
                    self.remoteItems.cancellAllRequests()
                    self.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
                }

            },
               newFieldValue: newFieldValue)
    }
    
    func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("BaseFilesGreedInteractor nextItems")

        guard isUpdating == false else {
            return
        }
        isUpdating = true
        getNextPageRetryCounter += 1
        remoteItems.nextItems(sortBy: sortBy,
                              sortOrder: sortOrder,
                              success: { [weak self] items in
                self?.getNextPageRetryCounter = 0
                DispatchQueue.main.async {
                    debugLog("BaseFilesGreedInteractor nextItems RemoteItemsService reloadItems success")

                    self?.isUpdating = false
                    guard let output = self?.output else { return }
                    if items.count == 0 {
                        output.getContentWithSuccessEnd()
                    } else if items.count > 0 {
                        output.getContentWithSuccess(items: items)
                    }
                }
            }, fail: { [weak self] in
                debugLog("BaseFilesGreedInteractor nextItems RemoteItemsService reloadItems fail")
                guard let `self` = self, let output = self.output else {
                    return
                }
                if self.getNextPageRetryCounter >= self.numberOfRetries {
                    self.getNextPageRetryCounter = 0
                    self.isUpdating = false
                    output.getContentWithFail(errorString: nil)
                } else {
                    self.isUpdating = false
                    self.remoteItems.cancellAllRequests()
                    self.nextItems(sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
                }
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
    
    func trackScreen() {
        guard let originalFilters = originalFilters else {
            return
        }
        for filter in originalFilters {
            switch filter {
            case .fileType(let fileType):
                switch fileType {
                case .image:
                    trackPhotoOrVideo(photo: true)
                case .video:
                    trackPhotoOrVideo(photo: false)
                case .audio:
                    analyticsManager.logScreen(screen: .music)
                    analyticsManager.trackDimentionsEveryClickGA(screen: .music)
                case .allDocs:
                    analyticsManager.logScreen(screen: .documents)
                    analyticsManager.trackDimentionsEveryClickGA(screen: .documents)
                default:
                    break
                }
            case .favoriteStatus(let favoriteStatus):
                if favoriteStatus == .favorites {
                    analyticsManager.logScreen(screen: .favorites)
                    analyticsManager.trackDimentionsEveryClickGA(screen: .favorites)
                }
            case .localStatus(let localStatus):
                if localStatus == .nonLocal,
                    remoteItems is AllFilesService {
                    analyticsManager.logScreen(screen: .allFiles)
                    analyticsManager.trackDimentionsEveryClickGA(screen: .allFiles)
                }
            default:
                break
            }
        }
    }
    
    func trackClickOnPhotoOrVideo(isPhoto: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: isPhoto ? .clickPhoto : .clickVideo)
    }
    
    func trackSortingChange(sortRule: SortedRules) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .sort, eventLabel: .sort(sortRule))
    }
    
    private func trackPhotoOrVideo(photo: Bool) {
        if remoteItems is PhotoAndVideoService {
            analyticsManager.logScreen(screen: photo ? .photos : .videos)
            analyticsManager.trackDimentionsEveryClickGA(screen: photo ? .photos : .videos)
        }
    }
    
    func trackFolderCreated() {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .newFolder)
    }
    
    func trackItemsSelected() {
        ///nothing here, need to override in create story interactor
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
    
    // MARK: - Utility methods
    private func needShowServerError() -> Bool {
        return remoteItems is MusicService ||
            remoteItems is DocumentService ||
            remoteItems is AllFilesService ||
            remoteItems is FavouritesService
    }
}
