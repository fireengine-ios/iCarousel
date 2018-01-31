//
//  FaceImageInteractorOutput.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol FaceImageInteractorOutput: class {
    func operationFinished()
    func showError(error: String)

    func didFaceImageStatus(_ isFaceImageAllowed: Bool)
    
    func failedChangeFaceImageStatus()
    
}
