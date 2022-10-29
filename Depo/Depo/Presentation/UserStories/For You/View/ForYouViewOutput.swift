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
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?, currentSection: ForYouSections)
    func navigateToAlbumDetail(album: AlbumItem)
    func navigateToItemPreview(item: WrapData, items: [WrapData], currentSection: ForYouSections)
    func getHeightForRow(at view: ForYouSections) -> Int
    func getModel(for view: ForYouSections) -> Any?
    func getUpdateData(for section: ForYouSections?)
    
    var currentSection: ForYouSections? {get set}
}
