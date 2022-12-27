//
//  BaseFilesGreedViewOutput.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol BaseFilesGreedViewOutput {

    func viewIsReady(collectionView: UICollectionView)
    
    func onReloadData()
    
    func needToReloadVisibleCells()
    
    func searchByText(searchText: String)
    
    func onStartCreatingPhotoAndVideos()
    
    func needShowNoFileView() -> Bool
    
    func getCurrentSortRule() -> SortedRules
    
    func getRemoteItemsService() -> RemoteItemsService
    
    func getFolder() -> Item?
    
    func onCancelSelection()
    
    func isSelectionState() -> Bool
    
    func viewWillDisappear()
    
    func viewWillAppear()

    func onNextButton()

    func getSortTypeString() -> String
    
    func viewAppearanceChangedTopBar(asGrid: Bool)
    
    func sortedPushedTopBar(with rule: MoreActionsConfig.SortRullesType)
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType])
    
    func moreActionsPressed(sender: Any)
    
    func searchPressed(output: UIViewController?)
    
    func openCreateNewStory(output: UIViewController?)
    
    func moveBack()
    
    func reloadType(_ type: MoreActionsConfig.ViewType, sortedType: MoreActionsConfig.SortRullesType, fieldType: FieldValue)
    
    func updateThreeDotsButton()
    
    func updateNoFilesView()
    
    func showOnlySyncedItems(_ value: Bool)
    
    func openPrivateShareFiles()
    
    func openPrivateSharedItem(entity: BaseDataSourceItem, sharedEnteties: [BaseDataSourceItem])
    
    func openCreateNewAlbum()
    
    func openUpload()
}
