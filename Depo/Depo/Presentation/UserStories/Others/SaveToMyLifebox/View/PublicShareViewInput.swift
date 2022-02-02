//
//  PublicShareViewInput.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol PublicShareViewInput: AnyObject, Waiting {
    func didGetSharedItems(items: [SharedFileInfo])
    func listOperationFail(with message: String, isInnerFolder: Bool)
    func saveOperationSuccess()
    func saveOpertionFail(errorMessage: String)
}
