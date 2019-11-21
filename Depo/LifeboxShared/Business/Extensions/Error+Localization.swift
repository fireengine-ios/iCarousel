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
            return TextConstants.errorConnectedToNetwork
        } else if notAuthorized {
            return String(format: TextConstants.errorLogin,
            TextConstants.NotLocalized.appName)
        }
        return localizedDescription
    }
}
