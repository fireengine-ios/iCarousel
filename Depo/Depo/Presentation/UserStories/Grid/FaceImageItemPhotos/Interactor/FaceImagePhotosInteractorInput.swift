//
//  FaceImagePhotosInteractorInput.swift
//  Depo
//
//  Created by Harhun Brothers on 2/26/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImagePhotosInteractorInput {
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64, title: String, message: String)
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64, title: String, message: String)
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], id: Int64, title: String, message: String)
}
