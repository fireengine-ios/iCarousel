//
//  ForYouPresenter.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ForYouPresenter: BasePresenter, ForYouModuleInput {
    weak var view: ForYouViewInput!
    var interactor: ForYouInteractorInput!
    var router: ForYouRouterInput!
}

extension ForYouPresenter: ForYouViewOutput {
    func onSeeAllButton(for view: ForYouViewEnum) {
        router.navigateToSeeAll(for: view)
    }
    
    func checkFIRisAllowed() {
        interactor.getFIRStatus { settings in
            guard let isFaceImageAllowed = settings.isFaceImageAllowed else { return }
            self.view.getFIRResponse(isAllowed: isFaceImageAllowed)
        } fail: { error in
            print(error.localizedDescription)
        }
    }
    
    func onFaceImageButton() {
        router.navigateToFaceImage()
    }
    
    func navigateToCreate(for view: ForYouViewEnum) {
        router.navigateToCreate(for: view)
    }
    
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?) {
        interactor.loadItem(item, faceImageType: faceImageType)
    }
    
    func navigateToAlbumDetail(album: AlbumItem) {
        router.navigateToAlbumDetail(album: album)
    }
}

extension ForYouPresenter: ForYouInteractorOutput {
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item, faceImageType: FaceImageType?) {
        router.navigateToItemDetail(album, forItem: item, faceImageType: faceImageType)
    }
}
