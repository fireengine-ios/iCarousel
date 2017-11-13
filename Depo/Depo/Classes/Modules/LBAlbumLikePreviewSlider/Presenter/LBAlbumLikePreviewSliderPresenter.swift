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
        interactor.requestAlbumbs()
    }
    
    var currentItems: [AlbumItem] {
        return interactor.currentItems
    }
    
    func sliderTitlePressed() {
        router.goToAlbumbsGreedView()   
    }
    
    func onSelectAlbumAt(index: Int){
        router.goToAlbumDetailView(album: interactor.currentItems[index])
    }
    
    func reloadData() {
        interactor.requestAlbumbs()
    }
    
    //MARK: - Presenter input
    
    func setup(withItems items: [AlbumItem]) {
        interactor.currentItems = items
        
        view.setupCollectionView()//withItems: items)
    }
    
    func reload() {
        interactor.requestAlbumbs()
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
