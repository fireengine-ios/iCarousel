//
//  ForYouRouterInput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouRouterInput {
    func navigateToSeeAll(for view: ForYouSections)
    func navigateToFaceImage()
    func navigateToCreate(for view: ForYouSections)
    func navigateToItemDetail(_ album: AlbumServiceResponse, forItem item: Item, faceImageType: FaceImageType?)
    func navigateToAlbumDetail(album: AlbumItem)
    func navigateToItemPreview(item: WrapData, items: [WrapData])
}
