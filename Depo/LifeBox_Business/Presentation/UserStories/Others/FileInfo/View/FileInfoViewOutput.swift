//
//  FileInfoFileInfoViewOutput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol FileInfoViewOutput {
    func viewIsReady()
    func shareItem()
    func showWhoHasAccess(shareInfo: SharedFileInfo)
    func openShareAccessList(contact: SharedContact)
}
