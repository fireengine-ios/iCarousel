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
}
