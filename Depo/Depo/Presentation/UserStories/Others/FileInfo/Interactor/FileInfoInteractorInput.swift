//
//  FileInfoFileInfoInteractorInput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol FileInfoInteractorInput {
    func setObject(object: BaseDataSourceItem)
    func viewIsReady()
    func onRename(newName: String)
    func getAlbum(for item: BaseDataSourceItem)
    func onValidateName(newName: String)
}
