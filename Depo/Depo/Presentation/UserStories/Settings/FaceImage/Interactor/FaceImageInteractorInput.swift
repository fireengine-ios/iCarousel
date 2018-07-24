//
//  FaceImageInteractorInput.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol FaceImageInteractorInput: class {
    func getFaceImageStatus()

    func changeFaceImageStatus(_ isAllowed: Bool)
    
    func trackScreen()
}
