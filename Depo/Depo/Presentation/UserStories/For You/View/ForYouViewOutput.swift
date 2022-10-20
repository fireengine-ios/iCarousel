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
    func onSeeAllButton(for view: ForYouViewEnum)
    func checkFIRisAllowed()
    func onFaceImageButton()
    func navigateToCreate(for view: ForYouViewEnum)
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?)
    func navigateToAlbumDetail(album: AlbumItem)
    func navigateToItemPreview(item: WrapData, items: [WrapData])
    func getHeightForRow(at view: ForYouViewEnum) -> Int
    func getModel(for view: ForYouViewEnum) -> Any?
}
