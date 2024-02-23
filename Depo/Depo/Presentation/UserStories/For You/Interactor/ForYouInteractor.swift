//
//  ForYouInteractor.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

typealias completion = (() -> Void)?

final class ForYouInteractor {
    weak var output: ForYouInteractorOutput!
    private lazy var accountService = AccountService()
    private lazy var cardsService: HomeCardsService = factory.resolve()
    private lazy var thingsService = ThingsService()
    private lazy var placesService = PlacesService()
    private lazy var peopleService = PeopleService()
    private lazy var albumServie = SearchService()
    private lazy var favoriteService = SearchService()
    private lazy var service = ForYouService()
    private lazy var hiddenService = HiddenService()
    private lazy var instapickService = InstapickServiceImpl()
    let group = DispatchGroup()
    
    private func getThings() {
        group.enter()
        debugLog("ForYou getThings")
        let param = ThingsPageParameters(pageSize: 10, pageNumber: 0)
        
        thingsService.getThingsPage(param: param, success: { [weak self] response in
            guard let response = response as? ThingsPageResponse else {
                return
            }
            self?.group.leave()
            self?.output.getThings(data: (response.list.map({ ThingsItem(response: $0) })))
        }, fail: { error in
            self.group.leave()
            debugLog("ForYou Error getThings: \(error.errorCode)-\(String(describing: error.errorDescriptionLog))")
            error.showInternetErrorGlobal()
        })
    }
    
    private func getPlaces() {
        debugLog("ForYou getPlaces")
        group.enter()
        let param = PlacesPageParameters(pageSize: 10, pageNumber: 0)

        placesService.getPlacesPage(param: param, success: { [weak self] response in
            guard let response = response as? PlacesPageResponse else {
                return
            }
            self?.group.leave()
            self?.output.getPlaces(data: (response.list.map({ PlacesItem(response: $0) })))
        }, fail: { error in
            self.group.leave()
            debugLog("ForYou Error getPlaces: \(error.errorCode)-\(String(describing: error.errorDescriptionLog))")
            error.showInternetErrorGlobal()
        })
    }
    
    private func getPeople() {
        debugLog("ForYou getPeople")
        group.enter()
        let param = PeoplePageParameters(pageSize: 10, pageNumber: 0)
        
        peopleService.getPeoplePage(param: param, success: { [weak self] response in
            guard let response = response as? PeoplePageResponse else {
                return
            }
            self?.group.leave()
            let filterResponse = response.list.filter({$0.visible == true})
            self?.output.getPeople(data: (filterResponse.map({ PeopleItem(response: $0) })))
        }, fail: { error in
            self.group.leave()
            debugLog("ForYou Error getPeople: \(error.errorCode)-\(String(describing: error.errorDescriptionLog))")
            error.showInternetErrorGlobal()
        })
    }
    
    private func getAlbums(completion: (() -> Void)? = nil) {
        debugLog("ForYou getAlbums")
        group.enter()
        
        let serchParam = AlbumParameters(fieldName: .album,
                                         sortBy: .date,
                                         sortOrder: .desc,
                                         page: 0,
                                         size: 10)
        
        albumServie.searchAlbums(param: serchParam, success: { [weak self] response in
            guard let resultResponse = response as? AlbumResponse else {
                return
            }
            
            let list = resultResponse.list.compactMap { AlbumItem(remote: $0) }
            self?.output.getAlbums(data: list.filter({ $0.preview?.id != nil }))
            self?.group.leave()
            
        }, fail: { errorResponse in
            self.group.leave()
            debugLog("ForYou Error getAlbums: \(errorResponse.errorCode)-\(String(describing: errorResponse.errorDescriptionLog))")
            errorResponse.showInternetErrorGlobal()
        })
    }
    
    private func getFavorites(completion: (() -> Void)? = nil) {
        debugLog("ForYou getFavorites")
        group.enter()
        
        let serchParam = SearchByFieldParameters(fieldName: .favorite,
                                                 fieldValue: .favorite,
                                                 sortBy: .name,
                                                 sortOrder: .desc,
                                                 page: 0,
                                                 size: 10)
        
        favoriteService.searchByField(param: serchParam, success: { [weak self] response in
            guard let resultResponse = response as? SearchResponse else {
                return
            }
            
            let list = resultResponse.list.filter({ $0.contentType == "image/jpeg" || $0.contentType == "image/png" || $0.contentType == "image/heic"
                                                 || $0.contentType == "video/mp4" || $0.contentType == "video/quicktime" })
            
            self?.output.getFavorites(data: list.map { WrapData(remote: $0) })
            self?.group.leave()
            
        }, fail: { errorResponse in
            self.group.leave()
            debugLog("ForYou Error getFavorites: \(errorResponse.errorCode)-\(String(describing: errorResponse.errorDescriptionLog))")
            errorResponse.showInternetErrorGlobal()
        })
    }
    
    private func getInstapickThumbnails() {
        debugLog("ForYou getInstapickThumbnails")
        group.enter()
        
        instapickService.getAnalyzeHistory(offset: 0, limit: 10) { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let history):
                self?.output.getPhotopicks(data: history)
            case .failed(let error):
                debugLog("ForYou Error getInstapickThumbnails: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getThrowbacks() {
        debugLog("ForYou getThrowbacks")
        group.enter()
        
        service.forYouThrowbacks() { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getThrowbacks(data: response)
            case .failed(let error):
                debugLog("ForYou Error getThrowbacks: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getStories() {
        debugLog("ForYou getStories")
        group.enter()

        service.forYouStories() { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getStories(data: response.fileList)
            case .failed(let error):
                debugLog("ForYou Error getStories: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getAnimations() {
        debugLog("ForYou getAnimations")
        group.enter()

        service.forYouAnimations() { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getAnimations(data: response.fileList)
            case .failed(let error):
                debugLog("ForYou Error getAnimations: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getCollages() {
        debugLog("ForYou getCollages")
        group.enter()

        service.forYouCollages() { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getCollages(data: response.fileList)
            case .failed(let error):
                debugLog("ForYou Error getCollages: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getCollageCards() {
        debugLog("ForYou getCollageCards")
        group.enter()

        service.forYouCards(for: .collageCards) { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getCollageCards(data: response)
            case .failed(let error):
                debugLog("ForYou Error getCollageCards: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getAlbumCards() {
        debugLog("ForYou getAlbumCards")
        group.enter()

        service.forYouCards(for: .albumCards) { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getAlbumCards(data: response)
            case .failed(let error):
                debugLog("ForYou Error getAlbumCards: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getAnimationCards() {
        debugLog("ForYou getAnimationCards")
        group.enter()

        service.forYouCards(for: .animationCards) { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getAnimationCards(data: response)
            case .failed(let error):
                debugLog("ForYou Error getAnimationCards: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getHiddens() {
        debugLog("ForYou getHiddens")
        group.enter()
        hiddenService.hiddenList(sortBy: .date, sortOrder: .desc, page: 0, size: 10) { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getHidden(data: response.fileList)
            case .failed(let error):
                debugLog("ForYou Error getHiddens: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getPrintedPhotos() {
        debugLog("ForYou getPrintedPhotos")
        group.enter()

        service.forYouPrintedPhotos() { [weak self] result in
            self?.group.leave()
            switch result {
            case .success(let response):
                self?.output.getPrintedPhotos(data: response)
            case .failed(let error):
                debugLog("ForYou Error getPrintedPhotos: \(error.description)-\(String(describing: error.description))")
                break
            }
        }
    }
    
    private func getTimeline() {
        debugLog("ForYou getTimeline")
        group.enter()

        service.forYouTimeline() { [weak self] result in
            self?.group.leave()

            switch result {
            case .success(let response):
                self?.output.getTimelineData(data: response)
            case .failed(let error):
                self?.output.setTimelineNilForError()
                debugLog("ForYou Error getTimeline: \(error.errorCode)-\(String(describing: error.description))")
                break
            }
        }
    }
}

extension ForYouInteractor: ForYouInteractorInput {
    func viewIsReady() {
        let timelineEnable = FirebaseRemoteConfig.shared.fetchTimelineEnabled
        if timelineEnable {
            getTimeline()
        }
        getThrowbacks()
        getThings()
        getPlaces()
        getPeople()
        getAlbums()
        getFavorites()
        getInstapickThumbnails()
        getStories()
        getAnimations()
        getCollages()
        getCollageCards()
        getHiddens()
        getAnimationCards()
        getAlbumCards()
        getPrintedPhotos()
        
        group.notify(queue: .main) {
            self.output?.didFinishedAllRequests()
        }
    }
    
    func getFIRStatus(success: @escaping (SettingsInfoPermissionsResponse) -> (), fail: @escaping (Error) -> ()) {
        accountService.getSettingsInfoPermissions { response in
            switch response {
            case .success(let result):
                success(result)
            case .failed(let error):
                fail(error)
            }
        }
    }
    
    func loadItem(_ item: BaseDataSourceItem, faceImageType: FaceImageType?) {
        guard let item = item as? Item, item.fileType.isFaceImageType, let id = item.id else {
            return
        }
        
        let successHandler: AlbumOperationResponse = { [weak self] album in
            DispatchQueue.main.async {
                self?.output.didLoadAlbum(album, forItem: item, faceImageType: faceImageType)
                self?.output?.asyncOperationSuccess()
            }
        }
        
        let failHandler: FailResponse = { [weak self] error in
            self?.output?.asyncOperationFail(errorMessage: error.description)
        }
        
        output.startAsyncOperation()
        
        if item is PeopleItem {
            peopleService.getPeopleAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
        } else if item is ThingsItem {
            thingsService.getThingsAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
        } else if item is PlacesItem {
            placesService.getPlacesAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
        }
    }
    
    func getUpdateData(for section: ForYouSections?) {
        guard let section = section else {
            return
        }
        
        switch section {
        case .faceImage:
            return
        case .throwback:
            getThrowbacks()
        case .people:
            getPeople()
        case .collageCards:
            getCollageCards()
        case .collages:
            getCollages()
        case .animationCards:
            getAnimationCards()
        case .animations:
            getAnimations()
        case .albumCards:
            getAlbumCards()
        case .albums:
            getAlbums()
        case .places:
            getPlaces()
        case .story:
            getStories()
        case .photopick:
            getInstapickThumbnails()
        case .things:
            getThings()
        case .hidden:
            getHiddens()
        case .favorites:
            getFavorites()
        case .printedPhotos:
            getPrintedPhotos()
        case .timeline:
            getTimeline()
        }
        
        group.notify(queue: .main) {
            self.output.didGetUpdateData()
        }
    }
    
    func onCloseCard(data: HomeCardResponse, section: ForYouSections) {
        debugLog("ForYou closeCard")
        guard let id = data.id else { return }

        cardsService.delete(with: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.output.closeCardSuccess(data: data, section: section)
                case .failed(_):
                    self?.output.closeCardFailed()
                }
            }
        }
    }
    
    func saveCard(data: HomeCardResponse, section: ForYouSections) {
        debugLog("ForYou saveCard")
        guard let id = data.id else { return }

        cardsService.save(with: id) { [weak self] result in
            switch result {
            case .success(_):
                self?.output.saveCardSuccess(data: data, section: section)
            case .failed(let error):
                if error.isOutOfSpaceError {
                    self?.output.saveCardFailedFullQuota(section: section)
                } else {
                    self?.output.saveCardFailed(section: section)
                }
            }
        }
    }
    
    func getThrowbackDetails(with item: ThrowbackData, completion: @escaping VoidHandler) {
        debugLog("ForYou throwbackDetails")
        guard let id = item.id else { return }

        service.forYouThrowbackDetails(id: id) { result in
            switch result {
            case .success(let data):
                self.output.getThrowbacksDetail(data: data)
            case .failed(_):
                self.output.throwbackDetailFailed()
            }
            completion()
        }
    }
    
    func saveTimelineCard(id: Int) {
        debugLog("ForYou saveTimelineCard")
        
        service.forYouSaveTimelineCard(with: id, handler: { [weak self] result in
            switch result {
            case .success(_):
                self?.output.saveTimelineCardSuccess(section: .timeline)
            case .failed(let error):
                if error.isOutOfSpaceError {
                    self?.output.saveCardFailedFullQuota(section: .timeline)
                } else {
                    self?.output.saveTimelineCardFail(section: .timeline)
                }
            }
        })
    }
    
    func deleteTimelineCard(id: Int) {
        debugLog("ForYou saveTimelineCard")
        
        service.forYouDeleteTimelineCard(with: id, handler: { [weak self] result in
            switch result {
            case .success(_):
                self?.output.deleteTimelineCardSuccess(section: .timeline)
            case .failed(let error):
                self?.output.deleteTimelineCardFail(section: .timeline)
            }
        })
    }
}
