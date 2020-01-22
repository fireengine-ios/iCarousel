//
//  FaceImagePhotosInteractorInput.swift
//  Depo
//
//  Created by Harhun Brothers on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImagePhotosInteractorInput {
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64)
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64)
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], id: Int64)
    
    func loadItem(_ item: BaseDataSourceItem)
    func updateCurrentItem(_ item: BaseDataSourceItem)
    func hideAlbum()
}
