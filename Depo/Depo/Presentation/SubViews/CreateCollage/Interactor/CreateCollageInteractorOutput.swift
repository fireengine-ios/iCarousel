//
//  CreateCollageInteractorOutput.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol CreateCollageInteractorOutput: AnyObject {
    func getCollageTemplate(data: [CollageTemplate])
    func didFinishedAllRequests()
}
