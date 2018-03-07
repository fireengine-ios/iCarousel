//
//  Error+Localization.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

extension Error {
    var parsedDescription: String {
        if isNetworkError {
            return L10n.errorInternet
        } else if notAuthorized {
            return L10n.errorLogin
        }
        return localizedDescription
    }
}

