//
//  MoreFilesActionsInteractorInput.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol MoreFilesActionsInteractorInput {
    
    
    func share(item: [BaseDataSourceItem], sourceRect: CGRect?)
    func shareViaLink(item: [BaseDataSourceItem], sourceRect: CGRect?)
    
    func info(item: [BaseDataSourceItem], isRenameMode: Bool)
    
    func edit(item: [BaseDataSourceItem], complition: VoidHandler?)
    
    func delete(item: [BaseDataSourceItem])
    
    func hide(items: [BaseDataSourceItem])
    
    func simpleHide(items: [BaseDataSourceItem])
    
    func completelyDelete(albums: [BaseDataSourceItem])
    
    func move(item: [BaseDataSourceItem], toPath: String)
    
    func sync(item: [BaseDataSourceItem])
    
    func download(item: [BaseDataSourceItem])
    
    
    // MARK: Actions Sheet
    
    func createStory(items: [BaseDataSourceItem])
    
    func copy(item: [BaseDataSourceItem], toPath: String)
    
    func addToFavorites(items: [BaseDataSourceItem])
    
    func removeFromFavorites(items: [BaseDataSourceItem])
    
    func addToAlbum(items: [BaseDataSourceItem])
    
    func backUp(items: [BaseDataSourceItem])
    
    func removeFromAlbum(items: [BaseDataSourceItem])
    
    func photos(items: [BaseDataSourceItem])
    
    func iCloudDrive(items: [BaseDataSourceItem])
    
    func lifeBox(items: [BaseDataSourceItem])
    
    func more(items: [BaseDataSourceItem])
    
    func select(items: [BaseDataSourceItem])
    
    func selectAll(items: [BaseDataSourceItem])
    
    func documentDetails(items: [BaseDataSourceItem])
    
    func addToPlaylist(items: [BaseDataSourceItem])
    
    func musicDetails(items: [BaseDataSourceItem])
    
    func shareAlbum(items: [BaseDataSourceItem])
    
    func makeAlbumCover(items: [BaseDataSourceItem])
    
    func albumDetails(items: [BaseDataSourceItem])
    
    func downloadToCmeraRoll(items: [BaseDataSourceItem])
    
    func deleteDeviceOriginal(items: [BaseDataSourceItem])
    
    func trackEvent(elementType: ElementTypes)
}
