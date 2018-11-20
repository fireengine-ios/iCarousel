//
//  AuthorityStorage.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol AuthorityStorage: class {
    var isPremium: Bool? { get set }
    var faceRecognition: Bool? { get set }
    var deleteDublicate: Bool? { get set }
    
    func refrashStatus(permissions: PermissionsResponse)
}
