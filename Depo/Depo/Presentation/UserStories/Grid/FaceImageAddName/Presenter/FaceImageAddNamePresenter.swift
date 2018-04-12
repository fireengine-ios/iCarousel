//
//  FaceImageAddNamePresenter.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class FaceImageAddNamePresenter: BaseFilesGreedPresenter {
    
    var currentItem: WrapData?
    
    weak var faceImagePhotosmoduleOutput: FaceImagePhotosModuleOutput?
    
    override func viewIsReady(collectionView: UICollectionView) {
        dataSource = FaceImageAddNameDataSource()
        super.viewIsReady(collectionView: collectionView)
        dataSource.isHeaderless = true
        dataSource.updateDisplayngType(type: .list)
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.cellForFaceImageAddName)
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    override func getCellSizeForList() -> CGSize {
        return CGSize(width: view.getCollectionViewWidth(), height: 53)
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        clearItems()
        super.getContentWithSuccess(items: items.filter { $0.id != currentItem?.id })
        asyncOperationSucces()
    }
    
    override func onItemSelected(item: BaseDataSourceItem, from data: [[BaseDataSourceItem]]) {
        if let router = router as? FaceImageAddNameRouterInput,
            let currentItem = currentItem,
            let currentItemURL = currentItem.urlToFile,
            let item = item as? WrapData,
            let itemUrl = item.urlToFile {
            let yesHandler: VoidHandler = { [weak self] in
                if let interactor = self?.interactor as? FaceImageAddNameInteractorInput {
                    self?.startAsyncOperation()
                    interactor.mergePeople(currentItem, otherPerson: item)
                }
            }

            router.showMerge(firstUrl: currentItemURL, secondUrl: itemUrl, completion: yesHandler)
        }
    }

    // MARK: - Utility methods
    
    private func clearItems() {
//        dataSource.allLocalItems = [WrapData]()
        dataSource.allMediaItems = [WrapData]()
        dataSource.allItems = [[WrapData]]()
    }

}

// MARK: - FaceImageAddNameViewOutput

extension FaceImageAddNamePresenter: FaceImageAddNameViewOutput {
    
    func onSearchPeople(_ text: String) {
        if let interactor = interactor as? FaceImageAddNameInteractorInput {
            interactor.getSearchPeople(text)
        }
    }
    
    func changeName(_ text: String) {
        if let interactor = interactor as? FaceImageAddNameInteractorInput {
            startAsyncOperation()
            if let id = currentItem?.id {
                interactor.setNewNameForPeople(text, personId: id)
            }
        }
    }
    
}

// MARK: - FaceImageInteractorOutput
    
extension FaceImageAddNamePresenter: FaceImageAddNameInteractorOutput {
    
    func didChangeName(_ name: String) {
        if let item = currentItem {
            currentItem?.name = name
            faceImagePhotosmoduleOutput?.didChangeName(item: item)
        }
        router.showBack()
    }
    
    func didMergePeople() {
        faceImagePhotosmoduleOutput?.didMergePeople()
        
        if let router = router as? FaceImageAddNameRouter {
            router.popToPeopleItems()
        }
    }
}
