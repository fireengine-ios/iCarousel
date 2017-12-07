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
    
    func searchByText(searchText: String)
    
    func onStartCreatingPhotoAndVideos()
    
    func needShowNoFileView()-> Bool
    
    func textForNoFileLbel() -> String
    
    func textForNoFileButton() -> String
    
    func imageForNoFileImageView() -> UIImage
    
    func getRemoteItemsService() -> RemoteItemsService
    
    func getFolder() -> Item?
    
    func onCancelSelection()
    
    func viewWillDisappear()
    
    func viewWillAppear()

    func onNextButton()

    func getSortTypeString() -> String
    
    func viewAppearanceChangedTopBar(asGrid: Bool)
    
    func sortedPushedTopBar(with rule:  MoreActionsConfig.SortRullesType)
    
    func filtersTopBar(cahngedTo filters: [MoreActionsConfig.MoreActionsFileType])
    
    func moreActionsPressed(sender: Any)
    
    func moveBack()
}
