//
//  GoogleUser.swift
//  Lifebox
//
//  Created by Burak Donat on 23.03.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

struct AppleGoogleUser {
    let idToken: String
    var email: String
    let type: AppleGoogleUserType
}

enum AppleGoogleUserType {
    case apple
    case google
    case none
}
