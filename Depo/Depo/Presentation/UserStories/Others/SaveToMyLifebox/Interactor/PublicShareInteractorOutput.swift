//
//  PublicShareInteractorOutput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol PublicShareInteractorOutput: AnyObject {
    func listOperationSuccess(with items: [SharedFileInfo])
    func startProgress()
    func listOperationFail(errorMessage: String, isToastMessage: Bool)
    func saveOperationSuccess()
    func saveOperationFail(errorMessage: String)
    func saveOperationStorageFail()
    func countOperationSuccess(with itemCount: Int)
    func countOperationFail()
    func createDownloadLinkSuccess(with url: String)
    func createDownloadLinkFail()
    func listAllItemsSuccess(with items: [SharedFileInfo])
    func listAllItemsFail(errorMessage: String, isToastMessage: Bool)
    func downloadOperationSuccess(with url: URL)
    func downloadOperationFailed()
    func downloadOperationContinue(downloadedByte: String)
    func downloadOperationStorageFail()
}
