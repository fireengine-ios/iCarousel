//
//  SearchViewRouterInput.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol SearchViewRouterInput {
    func onItemSelected(selectedItem: BaseDataSourceItem, sameTypeItems: [BaseDataSourceItem])
    func createStoryWithItems(_ items: [BaseDataSourceItem])
    func showNoFilesToCreateStoryAlert()
    func openFaceImageItems(category: SearchCategory)
    func openFaceImageItemPhotos(item: Item, album: AlbumItem)
    func openAlbum(item: AlbumItem)
}
