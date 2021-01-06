//
//  UploadFromLifeBoxInteractorIO.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UploadFromLifeBoxInteractorInput: class {
    
    func onUploadItems(items: [Item])
    
}

protocol UploadFromLifeBoxInteractorOutput: class {
    func uploadOperationSuccess()
    func asyncOperationFail(errorResponse: ErrorResponse)
}
