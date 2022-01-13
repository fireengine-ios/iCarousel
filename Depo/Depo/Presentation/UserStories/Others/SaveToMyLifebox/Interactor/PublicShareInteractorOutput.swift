//
//  PublicShareInteractorOutput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol PublicShareInteractorOutput: AnyObject {
    func operationSuccess(with items: [SharedFileInfo])
    func startProgress()
    func operationFailedWithError(errorMessage: String, needReturn: Bool)
    func saveOperationSuccess()
}
