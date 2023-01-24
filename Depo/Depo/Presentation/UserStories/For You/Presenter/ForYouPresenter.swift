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
    var currentSection: ForYouSections?
    
    private lazy var thingsData: [WrapData] = []
    private lazy var placesData: [WrapData] = []
    private lazy var peopleData: [WrapData] = []
    private lazy var albumsData: [AlbumItem] = []
    private lazy var photopickData: [InstapickAnalyze] = []
    private lazy var storyData: [WrapData] = []
    private lazy var animationsData: [WrapData] = []
    private lazy var collagesData: [WrapData] = []
    private lazy var hiddenData: [WrapData] = []
    private lazy var favoriteData: [WrapData] = []
    private lazy var collageCardsData: [HomeCardResponse] = []
    private lazy var albumCardsData: [HomeCardResponse] = []
    private lazy var animationCardsData: [HomeCardResponse] = []
    private lazy var throwbackData: [ThrowbackData] = []
    
    func viewIsReady() {
        interactor.viewIsReady()
        view.showSpinner()
    }
}

extension ForYouPresenter: ForYouViewOutput {
    func onSeeAllButton(for view: ForYouSections) {
        self.currentSection = view
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
        self.currentSection = view
        router.navigateToCreate(for: view)
    }
    
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?, currentSection: ForYouSections) {
        self.currentSection = currentSection
        interactor.loadItem(item, faceImageType: faceImageType)
    }
    
    func navigateToAlbumDetail(album: AlbumItem) {
        self.currentSection = .albums
        router.navigateToAlbumDetail(album: album)
    }
    
    func navigateToItemPreview(item: WrapData, items: [WrapData], currentSection: ForYouSections) {
        self.currentSection = currentSection
        router.navigateToItemPreview(item: item, items: items)
    }
    
    func navigateToThrowbackDetail(item: ThrowbackData) {
        self.currentSection = .throwback
        interactor.getThrowbackDetails(with: item)
    }
    
    func getHeightForRow(at view: ForYouSections) -> Int {
        switch view {
        case .faceImage:
            return 224
        case .throwback:
            return throwbackData.isEmpty ? 0 : 225
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
        case .favorites:
            return favoriteData.isEmpty ? 0 : 190
        }
    }
    
    func getModel(for view: ForYouSections) -> Any? {
        switch view {
        case .faceImage:
            return nil
        case .throwback:
            return throwbackData
        case .people:
            return peopleData
        case .things:
            return thingsData
        case .places:
            return placesData
        case .albums:
            return albumsData
        case .favorites:
            return favoriteData
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
    
    func displayAlbum(item: AlbumItem) {
        self.currentSection = .albumCards
        router.displayAlbum(item: item)
    }
    
    func displayCollage(item: WrapData) {
        router.displayItem(item: item)
    }
    
    func displayAnimation(item: WrapData) {
        router.displayItem(item: item)
    }
    
    func showSavedCollage(item: WrapData) {
        router.showSavedItem(item: item)
    }
    
    func showSavedAnimation(item: WrapData) {
        router.showSavedItem(item: item)
    }
    
    func getUpdateData(for section: ForYouSections?) {
        self.currentSection = section
        interactor.getUpdateData(for: section)
    }
    
    func onCloseCard(data: HomeCardResponse, section: ForYouSections) {
        view.showSpinner()
        interactor.onCloseCard(data: data, section: section)
    }
    
    func saveCard(data: HomeCardResponse, section: ForYouSections) {
        view.showSpinner()
        interactor.saveCard(data: data, section: section)
    }
    
    func emptyCardData(for section: ForYouSections) {
        switch section {
        case .collageCards:
            collageCardsData = []
        case .animationCards:
            animationCardsData = []
        case .albumCards:
            albumCardsData = []
        default:
            return
        }
    }
}

extension ForYouPresenter: ForYouInteractorOutput {
    func didGetUpdateData() {
        view.didGetUpdateData()
    }
    
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
    
    func getFavorites(data: [WrapData]) {
        self.favoriteData = data
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
    
    func getThrowbacks(data: [ThrowbackData]) {
        self.throwbackData = data
    }
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item, faceImageType: FaceImageType?) {
        router.navigateToItemDetail(album, forItem: item, faceImageType: faceImageType)
    }

    func didFinishedAllRequests() {
        view.hideSpinner()
        view.didFinishedAllRequests()
    }
    
    func closeCardSuccess(data: HomeCardResponse, section: ForYouSections) {
        view.hideSpinner()
    }
    
    func closeCardFailed() {
        view.hideSpinner()
        UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
    }
    
    func saveCardFailed(section: ForYouSections) {
        view.hideSpinner()
        view.saveCardFailed(section: section)
        UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
    }
    
    func saveCardFailedFullQuota(section: ForYouSections) {
        view.hideSpinner()
        view.saveCardFailed(section: section)
        router.showFullQuota()
    }
    
    func saveCardSuccess(data: HomeCardResponse, section: ForYouSections) {
        view.hideSpinner()
        view.saveCardSuccess(section: section)
    }
    
    func getThrowbacksDetail(data: ThrowbackDetailsData) {
        router.navigateToThrowbackDetail(item: data)
    }
    
    func throwbackDetailFailed() {
        UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
    }
}
