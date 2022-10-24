//
//  ForYouPresenter.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ForYouPresenter: BasePresenter, ForYouModuleInput {
    weak var view: ForYouViewInput!
    var interactor: ForYouInteractorInput!
    var router: ForYouRouterInput!
    
    private lazy var thingsData: [WrapData] = []
    private lazy var placesData: [WrapData] = []
    private lazy var peopleData: [WrapData] = []
    private lazy var albumsData: [AlbumItem] = []
    private lazy var photopickData: [InstapickAnalyze] = []
    private lazy var storyData: [WrapData] = []
    private lazy var animationsData: [WrapData] = []
    private lazy var collagesData: [WrapData] = []
    private lazy var hiddenData: [WrapData] = []
    private lazy var collageCardsData: [HomeCardResponse] = []
    private lazy var albumCardsData: [HomeCardResponse] = []
    private lazy var animationCardsData: [HomeCardResponse] = []
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.showSpinner()
    }
}

extension ForYouPresenter: ForYouViewOutput {
    func onSeeAllButton(for view: ForYouSections) {
        router.navigateToSeeAll(for: view)
    }
    
    func checkFIRisAllowed() {
        interactor.getFIRStatus { settings in
            guard let isFaceImageAllowed = settings.isFaceImageAllowed else { return }
            self.view.getFIRResponse(isAllowed: isFaceImageAllowed)
        } fail: { error in
            print(error.localizedDescription)
        }
    }
    
    func onFaceImageButton() {
        router.navigateToFaceImage()
    }
    
    func navigateToCreate(for view: ForYouSections) {
        router.navigateToCreate(for: view)
    }
    
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?) {
        interactor.loadItem(item, faceImageType: faceImageType)
    }
    
    func navigateToAlbumDetail(album: AlbumItem) {
        router.navigateToAlbumDetail(album: album)
    }
    
    func navigateToItemPreview(item: WrapData, items: [WrapData]) {
        router.navigateToItemPreview(item: item, items: items)
    }
    
    func getHeightForRow(at view: ForYouSections) -> Int {
        switch view {
        case .faceImage:
            return 224
        case .people:
            return peopleData.isEmpty ? 0 : 150
        case .things:
            return thingsData.isEmpty ? 0 : 190
        case .places:
            return placesData.isEmpty ? 0 : 190
        case .albums:
            return 190
        case .story:
            return 190
        case .animations:
            return animationsData.isEmpty ? 0 : 190
        case .collageCards:
            return collageCardsData.isEmpty ? 0 : 400
        case .animationCards:
            return animationCardsData.isEmpty ? 0 : 400
        case .albumCards:
            return albumCardsData.isEmpty ? 0 : 416
        case .collages:
            return collagesData.isEmpty ? 0 : 190
        case .hidden:
            return hiddenData.isEmpty ? 0 : 190
        case .photopick:
            return 190
        }
    }
    
    func getModel(for view: ForYouSections) -> Any? {
        switch view {
        case .faceImage:
            return nil
        case .people:
            return peopleData
        case .things:
            return thingsData
        case .places:
            return placesData
        case .albums:
            return albumsData
        case .story:
            return storyData
        case .animations:
            return animationsData
        case .collageCards:
            return collageCardsData
        case .collages:
            return collagesData
        case .hidden:
            return hiddenData
        case .photopick:
            return  photopickData.filter { $0.fileInfo != nil }
        case .animationCards:
            return animationCardsData
        case .albumCards:
            return albumCardsData
        }
    }
}

extension ForYouPresenter: ForYouInteractorOutput {
    func getThings(data: [WrapData]) {
        self.thingsData = data
    }
    
    func getPlaces(data: [WrapData]) {
        self.placesData = data
    }
    
    func getPeople(data: [WrapData]) {
        self.peopleData = data
    }
    
    func getStories(data: [WrapData]) {
        self.storyData = data
    }
    
    func getAnimations(data: [WrapData]) {
        self.animationsData = data
    }
    
    func getHidden(data: [WrapData]) {
        self.hiddenData = data
    }
    
    func getCollages(data: [WrapData]) {
        self.collagesData = data
    }
    
    func getAlbums(data: [AlbumItem]) {
        self.albumsData = data
    }
    
    func getPhotopicks(data: [InstapickAnalyze]) {
        self.photopickData = data
    }
    
    func getCollageCards(data: [HomeCardResponse]) {
        self.collageCardsData = data
    }
    
    func getAlbumCards(data: [HomeCardResponse]) {
        self.albumCardsData = data
    }
    
    func getAnimationCards(data: [HomeCardResponse]) {
        self.animationCardsData = data
    }
    
    func getThrowbacks(data: AlbumResponse) {
        //TODO: Facelift-Handle throwbacks
    }
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item, faceImageType: FaceImageType?) {
        router.navigateToItemDetail(album, forItem: item, faceImageType: faceImageType)
    }

    func didFinishedAllRequests() {
        view.hideSpinner()
        view.didFinishedAllRequests()
    }
}
