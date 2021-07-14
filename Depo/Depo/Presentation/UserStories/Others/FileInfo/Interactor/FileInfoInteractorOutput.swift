//
//  FileInfoFileInfoInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol FileInfoInteractorOutput: AnyObject {
    func setObject(object: BaseDataSourceItem)
    func updated()
    func albumForUuidSuccessed(album: AlbumServiceResponse)
    func albumForUuidFailed(error: Error)
    func failedUpdate(error: Error)
    func cancelSave(use name: String)
    func didValidateNameSuccess()
    func displayShareInfo(_ sharingInfo: SharedFileInfo)
}
