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
            self?.output.getPeople(data: (response.list.map({ PeopleItem(response: $0) })))
        }, fail: { error in
            self.group.leave()
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
            self?.output.getAlbums(data: list)
            self?.group.leave()
            
        }, fail: { errorResponse in
            self.group.leave()
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
            case .failed(_):
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
            case .failed(_):
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
            case .failed:
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
            case .failed:
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
            case .failed:
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
            case .failed:
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
            case .failed:
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
            case .failed:
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
            case .failed:
                break
            }
        }
    }
}

extension ForYouInteractor: ForYouInteractorInput {
    func viewIsReady() {
        getThrowbacks()
        getThings()
        getPlaces()
        getPeople()
        getAlbums()
        getInstapickThumbnails()
        getStories()
        getAnimations()
        getCollages()
        getCollageCards()
        getHiddens()
        getAnimationCards()
        getAlbumCards()
        
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
        }
        
        group.notify(queue: .main) {
            self.output.didGetUpdateData()
        }
    }
}
