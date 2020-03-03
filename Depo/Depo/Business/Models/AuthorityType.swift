//
//  AuthorityType.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 12/8/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

enum AuthorityType: String {
    static let typesInOffer: [AuthorityType] = [.faceRecognition, .deleteDublicate, .premiumUser]
    
    case faceRecognition    = "AUTH_FACE_IMAGE_LOCATION"
    case deleteDublicate    = "AUTH_DELETE_DUPLICATE"
    case premiumUser        = "AUTH_PREMIUM_USER"
    case middleUser         = "AUTH_MID_USER"
    case originalCopy       = "AUTH_ORIGINAL_COPY"
}
