//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderPresenter.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LBAlbumLikePreviewSliderPresenter {
    
    weak var view: LBAlbumLikePreviewSliderViewInput!
    var interactor: LBAlbumLikePreviewSliderInteractorInput!
    var router: LBAlbumLikePreviewSliderRouterInput!
    
    weak var faceImagePhotosModuleOutput: FaceImagePhotosModuleOutput?

    weak var baseGreedPresenterModule: BaseFilesGreedModuleInput?
    private let dataSource = LBAlbumLikePreviewSliderDataSource()
    
}

// MARK: LBAlbumLikePreviewSliderViewOutput

extension LBAlbumLikePreviewSliderPresenter: LBAlbumLikePreviewSliderViewOutput {
    
    func viewIsReady(collectionView: UICollectionView) {
        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        view.setupInitialState()
        
        if !interactor.currentItems.isEmpty {
            dataSource.setCollectionView(items: interactor.currentItems)
        } else {
            interactor.requestAllItems()
        }
    }
    
    func sliderTitlePressed() {
        router.goToAlbumbsGreedView()
    }
    
    func reloadData() {
        interactor.requestAllItems()
    }
    
}

// MARK: LBAlbumLikePreviewSliderInteractorOutput

extension LBAlbumLikePreviewSliderPresenter: LBAlbumLikePreviewSliderInteractorOutput {
    
    func operationSuccessed(withItems items: [SliderItem]) {
        dataSource.setCollectionView(items: items)
        faceImagePhotosModuleOutput?.getSliderItmes(items: items)
    }
    
    func operationFailed() { }
    
}

// MARK: LBAlbumLikePreviewSliderDataSourceDelegate

extension LBAlbumLikePreviewSliderPresenter: LBAlbumLikePreviewSliderDataSourceDelegate {
    
    func onItemSelected(item: SliderItem) {
        router.onItemSelected(item, moduleOutput: self)
    }
    
}

// MARK: LBAlbumLikePreviewSliderModuleInput

extension LBAlbumLikePreviewSliderPresenter: LBAlbumLikePreviewSliderModuleInput {
    
    func reloadAll() {
        interactor.requestAllItems()
    }
    
    func reload(types: [MyStreamType]) {
        interactor.reload(types: types)
    }
    
    func countThumbnailsFor(type: MyStreamType) -> Int {
        return interactor.currentItems.first(where: {$0.type == type})?.previewItems?.count ?? 0
    }
}
