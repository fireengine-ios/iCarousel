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
    
    private var allItems = [WrapData]()
    
    private var updatedMyStream = false
    
    private var containsInvisibleItems = false
    
    private var forceLoadNextItems = false
    
    private var featureType: FeaturePackageType = .appleFeature
    
    private var accountType: AccountType = .all
    
    private var alertText = ""
    
    private let sumMarginsForFooter: CGFloat = 60
    
    private let sumWidthMarginsForHeader: CGFloat = 30
    
    private let sumHeightMarginsForHeader: CGFloat = 40

    override func viewIsReady(collectionView: UICollectionView) {
        if let faceImageType = faceImageType {
            dataSource = FaceImageItemsDataSource(faceImageType: faceImageType, delegate: self)
            if let dataSource = dataSource as? FaceImageItemsDataSource {
                dataSource.heightTitleLabel = getHeightForTitleLabel()
                if faceImageType == .people {
                    dataSource.carouselViewHeight = getCarouselPagerMaxHeight()
                    dataSource.sumHeightMarginsForHeader = sumHeightMarginsForHeader
                }
            }
            
        }
        super.viewIsReady(collectionView: collectionView)
        
        dataSource.setPreferedCellReUseID(reUseID: CollectionViewCellsIdsConstant.cellForFaceImage)
        dataSource.isHeaderless = true
        
        if hasUgglaLabel(), let view = view as? FaceImageItemsViewInput {
            view.configurateUgglaView(hidden: !dataSource.isPaginationDidEnd)
        }
    }
    
    override func onReloadData() {
        super.onReloadData()
        
        if let view = view as? FaceImageItemsViewInput {
            view.hideUgglaView()
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
            peopleItem.uuid == item.uuid, peopleItem.responseObject.isDemo == false {
                peopleItem.responseObject.visible = !isVisible
            }
        }
    }
    
    override func onSelectedFaceImageDemoCell(with indexPath: IndexPath) {
        if let dataSource = dataSource as? FaceImageItemsDataSource {
            dataSource.didAnimationForPremiumButton(with: indexPath)
        }
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        if let interactor = interactor as? FaceImageItemsInteractorInput {
            interactor.changeCheckPhotosState(isCheckPhotos: false)
        }
        
        let filteredItems: [WrapData]
        if faceImageType == .people && !isChangeVisibilityMode, let peopleItems = items as? [PeopleItem] {
            filteredItems = peopleItems.filter { $0.urlToFile != nil && $0.responseObject.visible == true }
            if !containsInvisibleItems && peopleItems.first(where: { $0.urlToFile != nil && $0.responseObject.visible == false }) != nil {
                containsInvisibleItems = true
            }
        } else {
            filteredItems = items.filter { $0.urlToFile != nil }
        }
        
        //FIXME: remove other reload methods to avoid duplicates on view appear and made code below unneeded
        if interactor.requestPageNum == 1 {
            dataSource.dropData()
        }
        
        super.getContentWithSuccess(items: filteredItems)
        
        print("filteredItems count = \(filteredItems.count)")
        print("items count = \(items.count)")
        
        forceLoadNextItems = filteredItems.isEmpty && !items.isEmpty
        
        dataSource.isHeaderless = faceImageType != .people
        
        updateThreeDotsButton()
        updateUgglaViewIfNeed()
        updateMyStreamSliderIfNeed()
    }
    
    override func getContentWithSuccessEnd() {
        super.getContentWithSuccessEnd()
        
        updateNoFilesView()
        dataSource.hideLoadingFooter()
    
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
        
        if let view = view as? FaceImageItemsViewInput {
            let needShow = !dataSource.allMediaItems.isEmpty || (dataSource.allMediaItems.isEmpty && containsInvisibleItems)
            view.updateShowHideButton(isShow: needShow)
        }
        
        if forceLoadNextItems {
            dataSource.needReloadData = false
            forceLoadNextItems = false
            dataSource.isPaginationDidEnd = false
            dataSource.delegate?.getNextItems()
        } else {            
            dataSource.needReloadData = true
        }
    }
   
    override func getContentWithFail(errorString: String?) {
        super.getContentWithFail(errorString: errorString)
        updateThreeDotsButton()
    }
    
    override func onChangeSelectedItemsCount(selectedItemsCount: Int) { }
    
    override func needShowNoFileView() -> Bool {
        if isChangeVisibilityMode {
            return dataSource.allMediaItems.isEmpty && !containsInvisibleItems
        } else {
            return dataSource.allMediaItems.isEmpty && AuthoritySingleton.shared.faceRecognition
        }
    }
    
    override func updateThreeDotsButton() {
        //FIXME: we need solve memory leak, something holds presenter in memory
        guard let view = view else { return }
        view.setThreeDotsMenu(active: true)
    }
    
    // MARK: - BaseDataSourceForCollectionViewDelegate
    
    override func didDelete(items: [BaseDataSourceItem]) {
        reloadData()
    }
    
    override func updateCoverPhotoIfNeeded() {
        reloadData()
    }
    
    override func startAsyncOperation() {
        outputView()?.showSpinner()
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == dataSource.collectionView {
            updateUgglaViewIfNeed()
        }
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
        } else {
            view.hideNoFiles()
        }
    }
    
    func updateMyStreamSliderIfNeed() {
        // update my stream slider after upload photos
        if !updatedMyStream {
            if let type = faceImageType?.myStreamType,
                let count = albumSliderModuleOutput?.countThumbnailsFor(type: type),
                count < NumericConstants.myStreamSliderThumbnailsCount, count != allItems.count  {
                albumSliderModuleOutput?.reload(types: [type])
            }
            updatedMyStream = true
        }
    }
    
    // MARK: - Utility methods
    private func hasUgglaLabel() -> Bool {
        return faceImageType == .people || faceImageType == .things
    }
    
    private func switchVisibilityMode(_ isChangeVisibilityMode: Bool) {
        self.isChangeVisibilityMode = isChangeVisibilityMode
        dataSource.setSelectionState(selectionState: isChangeVisibilityMode)
        
        if let view = view as? FaceImageItemsViewInput {
            view.hideUgglaView()
        }
        
        reloadData()
    }
        
    private func updateUgglaViewIfNeed() {
        if hasUgglaLabel(), let view = view as? FaceImageItemsViewInput {
            DispatchQueue.main.async {
                view.updateUgglaViewPosition()
            }
        }
    }
    
    private func getHeightForDescriptionLabel(with description: String) -> CGFloat {
        let maxLabelWidth = UIScreen.main.bounds.width - sumMarginsForFooter
        return description.height(for: maxLabelWidth, font: UIFont.TurkcellSaturaMedFont(size: 20))
    }
    
    private func getHeightForTitleLabel() -> CGFloat {
        if let faceImageType = faceImageType {
            let description = String(format: TextConstants.faceImageFooterViewMessage, faceImageType.footerDescription)
            let maxLabelWidth = UIScreen.main.bounds.width - sumMarginsForFooter
            return description.height(for: maxLabelWidth, font: UIFont.TurkcellSaturaBolFont(size: 20))
        } else {
            return 0
        }
        
    }
    
    private func getCarouselPagerMaxHeight() -> CGFloat {
        var maxHeight: CGFloat = 0
        var other: CGFloat = 0
        let maxCellWidth: CGFloat = UIScreen.main.bounds.width - sumWidthMarginsForHeader
        
        for model in CarouselPagerDataSource.getCarouselPageModels() {
           other = model.text.height(for:maxCellWidth, font: UIFont.TurkcellSaturaDemFont(size: 14))
                   + model.title.height(for: maxCellWidth , font: UIFont.TurkcellSaturaFont(size: 13))
           maxHeight = max(maxHeight,other)
        }
        
        return maxHeight
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
                
        view.stopSelection()
        
        albumSliderModuleOutput?.reload(types: [.people])
        reloadData()
    }
    
    func didShowPopUp() {        
        if let router = router as? FaceImageItemsRouterInput {
            DispatchQueue.toMain {
                router.showPopUp()
            }
        }
    }
    
    func didFailed(errorMessage: String) {
        if let router = self.router as? FaceImageItemsRouter {
            router.display(error: errorMessage)
        }
    }
    
    func switchToTextWithoutPrice(isError: Bool) {
        if let dataSource = dataSource as? FaceImageItemsDataSource,
            let interactor = interactor as? FaceImageItemsInteractor{
            
            let errorDescription = isError ? TextConstants.serverErrorMessage : TextConstants.noDetailsMessage
            alertText = errorDescription
            
            dataSource.price = nil
            dataSource.detailMessage = errorDescription
            dataSource.heightDescriptionLabel = getHeightForDescriptionLabel(with: errorDescription)
            
            interactor.reloadFaceImageItems()
        }
    }
    
    func didObtainFeaturePrice(_ price: String) {
        if let dataSource = dataSource as? FaceImageItemsDataSource,
            let interactor = interactor as? FaceImageItemsInteractor{
            
            let description = String(format: TextConstants.useFollowingPremiumMembership, price)
            
            dataSource.price = price
            dataSource.detailMessage = description
            dataSource.heightDescriptionLabel = getHeightForDescriptionLabel(with: description)
            
            interactor.reloadFaceImageItems()
        }
    }
    
    func didObtainFeaturePacks(_ packs: [PackageModelResponse]) {
        featureType = accountType == .all ? .appleFeature : .SLCMFeature
        var premiumFeature: PackageModelResponse? = nil
        for feature in packs {
            if feature.featureType == featureType {
                
                if let authorities = feature.authorities,
                    let interactor = interactor as? FaceImageItemsInteractor,
                    authorities.contains(where: { return $0.authorityType == .faceRecognition }) {
                    
                    premiumFeature = feature
                    interactor.getPriceInfo(offer: feature, accountType: accountType)
                    break
                }
            }
        }
        
        if premiumFeature == nil {
            switchToTextWithoutPrice(isError: false)
        }
    }
    
    func didObtainAccountType(_ accountType: String) {
        if accountType == "TURKCELL" {
            self.accountType = .turkcell
        }
        
        (dataSource as? FaceImageItemsDataSource)?.accountType = self.accountType
        
        if let interactor = interactor as? FaceImageItemsInteractor {
            interactor.getFeaturePacks()
        }
    }
    
    func didObtainAccountPermision(isAllowed: Bool) {
        if !isAllowed {
            if let interactor = interactor as? FaceImageItemsInteractorInput {
                interactor.checkAccountType()
            }
        } else {
            if let interactor = interactor as? FaceImageItemsInteractorInput {
                interactor.reloadFaceImageItems()
            }
        }
    }
}

// MARK: FaceImageItemsViewOutput

extension FaceImageItemsPresenter: FaceImageItemsViewOutput {
    
    func switchVisibilityMode() {
        switchVisibilityMode(!isChangeVisibilityMode)
    }
    
    func saveVisibilityChanges() {
        getSelectedItems { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            if let interactor = self.interactor as? FaceImageItemsInteractor,
                !selectedItems.isEmpty {
                
                let peopleItems = selectedItems.flatMap { $0 as? PeopleItem }
                interactor.onSaveVisibilityChanges(peopleItems)
                
            } else {
                self.view.stopSelection()
                
                self.switchVisibilityMode(!self.isChangeVisibilityMode)
            }
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

// MARK: - FaceImageDataSourceDelegate
extension FaceImageItemsPresenter: FaceImageItemsDataSourceDelegate {
    
    func onBecomePremiumTap() {
        if let router = router as? FaceImageItemsRouter, let dataSource = dataSource as? FaceImageItemsDataSource {
            if let price = dataSource.price, !price.isEmpty {
                router.openPremium(title: TextConstants.lifeboxPremium,
                                   headerTitle: TextConstants.becomePremiumMember,
                                   module: self)
            } else {
                router.showNoDetailsAlert(with: alertText)
            }
        }
    }
}
