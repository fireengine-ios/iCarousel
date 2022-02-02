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
    func listOperationFail(errorMessage: String, isInnerFolder: Bool)
    func saveOperationSuccess()
    func saveOperationFail(errorMessage: String)
    func saveOperationStorageFail()
}
