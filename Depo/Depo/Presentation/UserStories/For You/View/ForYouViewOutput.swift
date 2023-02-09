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
    func navigateToThrowbackDetail(item: ThrowbackData, completion: @escaping VoidHandler)
    func getHeightForRow(at view: ForYouSections) -> Int
    func getModel(for view: ForYouSections) -> Any?
    func getUpdateData(for section: ForYouSections?)
    
    func onCloseCard(data: HomeCardResponse, section: ForYouSections)
    func displayAlbum(item: AlbumItem)
    func displayAnimation(item: WrapData)
    func displayCollage(item: WrapData)
    func showSavedCollage(item: WrapData)
    func showSavedAnimation(item: WrapData)
    func saveCard(data: HomeCardResponse, section: ForYouSections)
    func emptyCardData(for section: ForYouSections)
    
    var currentSection: ForYouSections? {get set}
}
