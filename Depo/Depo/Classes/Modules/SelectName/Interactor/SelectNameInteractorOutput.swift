//
//  SelectNameSelectNameInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SelectNameInteractorOutput: class {
    
    func startProgress()
    
    func operationSucces(operation: SelectNameScreenType)
    
    func operationFaildWithError(error: String)
    
}
