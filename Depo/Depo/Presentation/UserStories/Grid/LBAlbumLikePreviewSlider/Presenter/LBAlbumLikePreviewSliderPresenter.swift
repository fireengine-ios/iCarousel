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
    
    weak var faceImagePhotosModuleOutput: FaceImagePhotosModuleOutput?

    weak var baseGreedPresenterModule: BaseFilesGreedModuleInput?
    var dataSource: LBAlbumLikePreviewSliderDataSource = LBAlbumLikePreviewSliderDataSource()
    
    // MARK: - View output
    
    func viewIsReady(collectionView: UICollectionView) {
        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        view.setupInitialState()
        interactor.requestAllItems()
    }
        
    func sliderTitlePressed() {
        router.goToAlbumbsGreedView()   
    }
    
    func reloadData() {
        interactor.requestAllItems()
    }
    
    // MARK: - Presenter input
    
    func setup(withItems items: [SliderItem]) {
        interactor.currentItems = items        
        dataSource.setCollectionView(items: items)
    }
    
    func reload() {
        interactor.requestAllItems()
    }
    
    // MARK: - Iteractor output
    
    func operationSuccessed(withItems items: [SliderItem]) {
        dataSource.setCollectionView(items: items)
        faceImagePhotosModuleOutput?.getSliderItmes(items: items)
    }
    
    func operationFailed() {
        
    }

}

extension LBAlbumLikePreviewSliderPresenter: LBAlbumLikePreviewSliderDataSourceDelegate {
    
    func onItemSelected(item: SliderItem) {
        router.onItemSelected(item, moduleOutput: self)
    }
}
