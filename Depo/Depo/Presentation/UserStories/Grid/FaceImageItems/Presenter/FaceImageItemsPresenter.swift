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
    
    private var allItmes: [WrapData] = []
    
    override func viewIsReady(collectionView: UICollectionView) {        
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.cellForFaceImage)
        dataSource.isHeaderless = true
        
        if hasUgglaLabel(), let view = view as? FaceImageItemsViewInput {
            view.configurateUgglaView(hidden: !dataSource.isPaginationDidEnd)
        }
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let interactor = interactor as? FaceImageItemsInteractor {
            interactor.loadItem(item)
        }
    }
    
    override func onItemSelectedActiveState(item: BaseDataSourceItem) {
        dataSource.allMediaItems.forEach { peopleItem in
            if let peopleItem = peopleItem as? PeopleItem,
            let isVisible = peopleItem.responseObject.visible,
            peopleItem.uuid == item.uuid {
                peopleItem.responseObject.visible = !isVisible
            }
        }
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        if let interactor = interactor as? FaceImageItemsInteractorInput {
            interactor.changeCheckPhotosState(isCheckPhotos: false)
        }
        allItmes = []
        
        if let view = view as? FaceImageItemsViewInput {
            view.updateShowHideButton(isShow: !items.isEmpty)
        }
        
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
        
        dataSource.isHeaderless = true
        updateThreeDotsButton()
        updateUgglaViewIfNeed()
    }
    
    override func getContentWithSuccessEnd() {
        super.getContentWithSuccessEnd()
        
        updateNoFilesView()

        if hasUgglaLabel(), let view = view as? FaceImageItemsViewInput {
            view.showUgglaView()
        }
        
        if let interactor = interactor as? FaceImageItemsInteractorInput {
            interactor.checkPhotos()
        }
    }
    
    override func filesAppendedAndSorted() {
        super.filesAppendedAndSorted()
        updateUgglaViewIfNeed()
    }
    
    override func getContentWithFail(errorString: String?) {
        super.getContentWithFail(errorString: errorString)
        updateThreeDotsButton()
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    override func needShowNoFileView() -> Bool {
        return dataSource.allMediaItems.isEmpty
    }
    
    private func updateUgglaViewIfNeed() {
        if hasUgglaLabel(), let view = view as? FaceImageItemsViewInput {
            DispatchQueue.main.async {
                view.updateUgglaViewPosition()
            }
        }
    }
    
    // MARK: - BaseDataSourceForCollectionViewDelegate
    
    override func didDelete(items: [BaseDataSourceItem]) {
        reloadData()
    }
    
    override func updateCoverPhotoIfNeeded() {
        reloadData()
    }
    
    override func startAsyncOperation() {
        outputView()?.showSpiner()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == dataSource.collectionView {
            updateUgglaViewIfNeed()
        }
    }
    
    private func hasUgglaLabel() -> Bool {
        return faceImageType == .people || faceImageType == .things
    }
    
    // MARK: - Utility methods
    
    private func switchVisibilityMode(_ isChangeVisibilityMode: Bool) {
        self.isChangeVisibilityMode = isChangeVisibilityMode
        dataSource.setSelectionState(selectionState: isChangeVisibilityMode)
        reloadData()
    }
    
    override func updateNoFilesView() {
        if needShowNoFileView() {
            if let view = view as? FaceImageItemsViewInput {
                view.showNoFilesWith(text: interactor.textForNoFileLbel(),
                                     image: interactor.imageForNoFileImageView(),
                                     createFilesButtonText: interactor.textForNoFileButton(),
                                     needHideTopBar: interactor.needHideTopBar(),
                                     isShowUggla: hasUgglaLabel())
            }
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
        
        if let view = view as? FaceImageItemsViewInput {
            view.hideUgglaView()
        }
        
        reloadData()
    }
    
    func didShowPopUp() {        
        if let router = router as? FaceImageItemsRouterInput {
            router.showPopUp()
        }
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
        dataSource.allMediaItems.forEach { people in
            if people.uuid == item.uuid {
                people.name = item.name
            }
        }

        dataSource.reloadData()
    }
    
    func didReloadData() {
        reloadData()
    }

    func delete(item: Item) {
        dataSource.deleteItems(items: [item])
    }
}
