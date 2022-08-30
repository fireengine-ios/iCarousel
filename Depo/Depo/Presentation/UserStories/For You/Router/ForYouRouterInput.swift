//
//  ForYouRouterInput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouRouterInput {
    func navigateToSeeAll(for view: ForYouViewEnum)
    func navigateToFaceImage()
    func navigateToCreate(for view: ForYouViewEnum)
    func navigateToItemDetail(_ album: AlbumServiceResponse, forItem item: Item)
    func navigateToAlbumDetail(album: AlbumItem)
}
