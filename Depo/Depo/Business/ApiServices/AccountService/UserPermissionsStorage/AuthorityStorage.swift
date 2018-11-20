//
//  AuthorityStorage.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol AuthorityStorage: class {
    var isPremium: String? { get set }
    var faceRecognition: String? { get set }
    var deleteDublicate: String? { get set }
    
    func refrashStatus(permissions: PermissionsResponse)
}
