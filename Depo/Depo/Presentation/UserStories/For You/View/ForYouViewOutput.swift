//
//  ForYouViewOutput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouViewOutput: AnyObject {
    func viewIsReady()
    func onSeeAllButton(for view: ForYouSections)
    func checkFIRisAllowed()
    func onFaceImageButton()
    func navigateToCreate(for view: ForYouSections)
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?)
    func navigateToAlbumDetail(album: AlbumItem)
    func navigateToItemPreview(item: WrapData, items: [WrapData])
    func getHeightForRow(at view: ForYouSections) -> Int
    func getModel(for view: ForYouSections) -> Any?
    
    func getUpdateAlbums()
    func getUpdatePeople()
    func getUpdateThings()
    func getUpdatePlaces()
    func getUpdateStories()
}
