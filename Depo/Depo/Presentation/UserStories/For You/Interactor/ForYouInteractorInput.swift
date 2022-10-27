//
//  ForYouInteractorInput.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouInteractorInput {
    func getFIRStatus(success: @escaping (SettingsInfoPermissionsResponse) -> (), fail: @escaping (Error) -> ())
    func loadItem(_ item: BaseDataSourceItem, faceImageType: FaceImageType?)
    func viewIsReady()
    
    func getUpdateAlbums()
    func getUpdatePlaces()
    func getUpdateThings()
    func getUpdatePeople()
    func getUpdateStories()
}

