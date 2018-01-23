//
//  URLs.swift
//  iGuru
//
//  Created by Yaroslav Bondar on 03.02.17.
//  Copyright © 2017 Yaroslav Bondar. All rights reserved.
//

import Foundation

enum URLs {
    static let baseUrl = try! "https://adepo.turkcell.com.tr/api/".asURL()
    static let refreshAccessToken = baseUrl +/ "auth/rememberMe"
}
