//
//  BaseFilesGreedInteractorInput.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol BaseFilesGreedInteractorInput {
    
    func viewIsReady()
    
    var remoteItems: RemoteItemsService { get }
    
    func nextItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?)
    
    func reloadItems (_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?)
    
    func canShowNoFilesView() -> Bool
    
    func needHideTopBar() -> Bool 
    
    func textForNoFileTopLabel() -> String
    
    func textForNoFileLbel() -> String
    
    func textForNoFileButton() -> String
    
    func imageForNoFileImageView() -> UIImage
    
    func getRemoteItemsService() -> RemoteItemsService
    
    func getFolder() -> Item?
    
    func trackScreen()
    func trackClickOnPhotoOrVideo(isPhoto: Bool)
    func trackSortingChange(sortRule: SortedRules)
    func trackFolderCreated()///Maybe shift into Operation manager
    func trackItemsSelected(item: BaseDataSourceItem)///Only for create story for now
    
    var bottomBarConfig: EditingBarConfig? { get set }
    
    var alerSheetMoreActionsConfig: AlertFilesActionsSheetInitialConfig? { get }
    
    var originalFilesTypeFilter: [GeneralFilesFiltrationType]? { get set }
    
    func getAllItems(sortBy: SortedRules)
    
    var requestPageSize: Int { get }
    
    var requestPageNum: Int {get}
    
}
