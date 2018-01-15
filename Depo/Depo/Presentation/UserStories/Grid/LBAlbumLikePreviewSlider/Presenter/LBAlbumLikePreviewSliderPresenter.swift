//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderPresenter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderPresenter: LBAlbumLikePreviewSliderModuleInput, LBAlbumLikePreviewSliderViewOutput, LBAlbumLikePreviewSliderInteractorOutput {

    weak var view: LBAlbumLikePreviewSliderViewInput!
    var interactor: LBAlbumLikePreviewSliderInteractorInput!
    var router: LBAlbumLikePreviewSliderRouterInput!

    weak var baseGreedPresenterModule: BaseFilesGreedModuleInput?
    
    
    //MARK: - View output
    
    func viewIsReady() {
        view.setupInitialState()
        interactor.requestAllItems()
    }
    
    func previewItems(withType type: MyStreamType) -> [Item] {
        var items: [Item]
 
        switch type {
        case .album:
            items = Array(interactor.albumItems.prefix(4).flatMap {$0.preview})
        case .story:
            items = Array(interactor.storyItems.prefix(4))
        case .people:
            items = Array(interactor.peopleItems.prefix(4))
        case .things:
            items = Array(interactor.thingItems.prefix(4))
        case .places:
            items = Array(interactor.placeItems.prefix(4))
        }
        return items
    }
    
    func sliderTitlePressed() {
        router.goToAlbumbsGreedView()   
    }
    
    func onSelectItem(type: MyStreamType) {
        switch type {
        case .album: router.goToAlbumbsGreedView()
        case .story: router.goToStoryListView()
        case .places: router.goToPlaceListView()
        case .things: router.goToThingListView()
        case .people: router.goToPeopleListView()
        }
    }
    
    func reloadData() {
        interactor.requestAllItems()
    }
    
    //MARK: - Presenter input
    
    func setup(withItems albumItems: [AlbumItem] = [], storyItems: [Item] = [], peopleItems: [Item], thingItems: [Item], placeItems: [Item]) {
        interactor.albumItems = albumItems
        interactor.storyItems = storyItems
        interactor.peopleItems = peopleItems
        interactor.thingItems = thingItems
        interactor.placeItems = placeItems
        
        view.setupCollectionView()
    }
    
    func reload() {
        interactor.requestAllItems()
    }
    
    //MARK: - Iteractor output
    
    func operationSuccessed() {
        view.setupCollectionView()
    }
    
    func operationFailed() {
        
    }
    
    func preparedAlbumbs(albumbs: [AlbumItem]) {
        setupCarousel()
    }
    
    
    //MARK: - Internal
    
    private func setupCarousel() {
        view.setupCollectionView()
    }
    
    
    //MARK: -
}
