//
//  MoreFilesActionsInteractorInput.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol MoreFilesActionsInteractorInput {
    
    func originalShare(item: [BaseDataSourceItem], sourceRect: CGRect?)
    
    func privateShare(item: [BaseDataSourceItem], sourceRect: CGRect?)
    
    func shareViaLink(item: [BaseDataSourceItem], sourceRect: CGRect?)
    
    func info(item: [BaseDataSourceItem])
    
    func moveToTrash(items: [BaseDataSourceItem])
    
    func move(item: [BaseDataSourceItem], toPath: String)
    
    func download(item: [BaseDataSourceItem])
    
    func downloadDocument(items: [WrapData]?)
    
    func restore(items: [BaseDataSourceItem])
    
    // MARK: Actions Sheet
    
    func copy(item: [BaseDataSourceItem], toPath: String)
    
    func addToFavorites(items: [BaseDataSourceItem])
    
    func removeFromFavorites(items: [BaseDataSourceItem])
    
    func backUp(items: [BaseDataSourceItem])
    
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
    
    func delete(items: [BaseDataSourceItem])

    func deletePermanently(items: [BaseDataSourceItem])
    
    func emptyTrashBin()
    
    func endSharing(item: BaseDataSourceItem?)
    
    func leaveSharing(item: BaseDataSourceItem?)
    
    func moveToTrashShared(items: [BaseDataSourceItem])
}
