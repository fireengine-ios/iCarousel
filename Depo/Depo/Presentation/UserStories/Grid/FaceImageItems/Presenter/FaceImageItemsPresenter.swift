//
//  FaceImageItemsPresenter.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsPresenter: BaseFilesGreedPresenter {

    weak var albumSliderModuleOutput: LBAlbumLikePreviewSliderModuleInput?
    
    var faceImageType: FaceImageType?
    
    private var isChangeVisibilityMode: Bool = false
    
    private var visibilityItems: [WrapData] = []
    private var allItmes: [WrapData] = []
    
    override func viewIsReady(collectionView: UICollectionView) {        
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.cellForFaceImage)
        dataSource.isHeaderless = true
        
        if hasUgglaLabel(), let view = view as? FaceImageItemsInput {
            view.configurateUgglaView()
        }
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interactor = interactor as? FaceImageItemsInteractor {
            interactor.loadItem(item)
        }
    }
    
    func onItemSelectedActiveState(item: BaseDataSourceItem) {
        dataSource.allMediaItems.forEach { peopleItem in
            if let peopleItem = peopleItem as? PeopleItem,
            let isVisible = peopleItem.responseObject.visible,
            peopleItem.uuid == item.uuid {
                peopleItem.responseObject.visible = !isVisible
            }
        }
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        allItmes = []
        
        items.forEach { item in
            guard item.urlToFile != nil else { return }

            if isChangeVisibilityMode {
                allItmes.append(item)
            } else if let peopleItem = item as? PeopleItem,
                let isVisible = peopleItem.responseObject.visible {
                if isVisible { allItmes.append(item) }
            } else {
                allItmes.append(item)
            }
        }
        
        super.getContentWithSuccess(items: allItmes)
        
        albumSliderModuleOutput?.reload()
        
        if hasUgglaLabel(), let view = view as? FaceImageItemsInput {
            DispatchQueue.main.async {
                view.updateUgglaViewPosition()
            }
        }
        
        dataSource.isHeaderless = true
        updateNoFilesView()
    }
    
    override func getContentWithFail(errorString: String?) {
        super.getContentWithFail(errorString: errorString)
        
        updateNoFilesView()
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    override func needShowNoFileView() -> Bool {
        return dataSource.allMediaItems.isEmpty
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if hasUgglaLabel(), let view = view as? FaceImageItemsInput, scrollView == dataSource.collectionView {
            view.updateUgglaViewPosition()
        }
    }
    
    private func hasUgglaLabel() -> Bool {
        return faceImageType == .people || faceImageType == .things
    }
    
    // MARK: -  Utility methods
    
    private func switchVisibilityMode(_ isChangeVisibilityMode: Bool) {
        self.isChangeVisibilityMode = isChangeVisibilityMode
        dataSource.setSelectionState(selectionState: isChangeVisibilityMode)
        reloadData()
    }
    
    private func updateNoFilesView() {
        if needShowNoFileView() {
            view.showNoFilesWith(text: interactor.textForNoFileLbel(),
                                    image: interactor.imageForNoFileImageView(),
                                    createFilesButtonText: "", needHideTopBar: interactor.needHideTopBar())
        }
    }
}

// MARK: FaceImageItemsInteractorOutput

extension FaceImageItemsPresenter: FaceImageItemsInteractorOutput {
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item) {
        if let router = router as? FaceImageItemsRouter {
            let albumItem = AlbumItem(remote: album)
            router.openFaceImageItemPhotosWith(item, album: albumItem, moduleOutput: self)
        }
    }
    
    func didSaveChanges(_ items: [PeopleItem]) {
        isChangeVisibilityMode = false
        dataSource.setSelectionState(selectionState: false)
        
        asyncOperationSucces()
        
        view.stopSelection()
        
        reloadData()
    }
    
}

// MARK: FaceImageItemsViewOutput

extension FaceImageItemsPresenter: FaceImageItemsViewOutput {
    
    func switchVisibilityMode() {
        switchVisibilityMode(!isChangeVisibilityMode)
    }
    
    func saveVisibilityChanges() {
        if let interactor = interactor as? FaceImageItemsInteractor,
            !selectedItems.isEmpty {
            
            let peopleItems = selectedItems.flatMap { $0 as? PeopleItem }
            interactor.onSaveVisibilityChanges(peopleItems)
            
        } else {
            view.stopSelection()
            
            switchVisibilityMode(!isChangeVisibilityMode)
        }
    }
    
}

// MARK: FaceImageItemsViewOutput

extension FaceImageItemsPresenter: FaceImageItemsModuleOutput {
    
    func didChangeName(item: WrapData) {
        reloadData()
    }
    
    func didReloadData() {
        reloadData()
    }

    func delete(item: Item) {
        dataSource.deleteItems(items: [item])
    }
}
