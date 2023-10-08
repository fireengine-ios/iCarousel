//
//  ForYouInteractorOutput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouInteractorOutput: AnyObject {
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item, faceImageType: FaceImageType?)
    func asyncOperationSuccess()
    func asyncOperationFail(errorMessage: String?)
    func startAsyncOperation()
    
    func getThings(data: [WrapData])
    func getPlaces(data: [WrapData])
    func getPeople(data: [WrapData])
    func getStories(data: [WrapData])
    func getAnimations(data: [WrapData])
    func getHidden(data: [WrapData])
    func getFavorites(data: [WrapData])
    func getCollages(data: [WrapData])
    func getPrintedPhotos(data: [GetOrderResponse])
    func getAlbums(data: [AlbumItem])
    func getPhotopicks(data: [InstapickAnalyze])
    func getCollageCards(data: [HomeCardResponse])
    func getAlbumCards(data: [HomeCardResponse])
    func getAnimationCards(data: [HomeCardResponse])
    func getThrowbacks(data: [ThrowbackData])
    func getThrowbacksDetail(data: ThrowbackDetailsData)
    
    func didFinishedAllRequests()
    func didGetUpdateData()
    
    func closeCardFailed()
    func closeCardSuccess(data: HomeCardResponse, section: ForYouSections)
    func saveCardFailed(section: ForYouSections)
    func saveCardFailedFullQuota(section: ForYouSections)
    func saveCardSuccess(data: HomeCardResponse, section: ForYouSections)
    func throwbackDetailFailed()
}
