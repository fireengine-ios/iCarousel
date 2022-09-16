//
//  ForYouInteractor.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ForYouInteractor: ForYouInteractorInput {
    weak var output: ForYouInteractorOutput!
    private lazy var accountService = AccountService()
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    
    func getFIRStatus(success: @escaping (SettingsInfoPermissionsResponse) -> (), fail: @escaping (Error) -> ()) {
        accountService.getSettingsInfoPermissions { response in
            switch response {
            case .success(let result):
                success(result)
            case .failed(let error):
                fail(error)
            }
        }
    }
    
    func loadItem(_ item: BaseDataSourceItem, faceImageType: FaceImageType?) {
        guard let item = item as? Item, item.fileType.isFaceImageType, let id = item.id else {
            return
        }
        
        let successHandler: AlbumOperationResponse = { [weak self] album in
            DispatchQueue.main.async {
                self?.output.didLoadAlbum(album, forItem: item, faceImageType: faceImageType)
                self?.output?.asyncOperationSuccess()
            }
        }
        
        let failHandler: FailResponse = { [weak self] error in
            self?.output?.asyncOperationFail(errorMessage: error.description)
        }
        
        output.startAsyncOperation()
        
        if item is PeopleItem {
            peopleService.getPeopleAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
        } else if item is ThingsItem {
            thingsService.getThingsAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
        } else if item is PlacesItem {
            placesService.getPlacesAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
        }
    }
}
