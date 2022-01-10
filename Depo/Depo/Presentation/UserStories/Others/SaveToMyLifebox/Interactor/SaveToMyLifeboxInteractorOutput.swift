//
//  SaveToMyLifeboxInteractorOutput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol SaveToMyLifeboxInteractorOutput: AnyObject {
    func operationSuccess(with items: [SharedFileInfo])
    func startProgress()
    func operationFailedWithError(errorMessage: String)
    func saveOperationSuccess()
}
