//
//  AuthorizationURLs.swift
//  NetworingAuth
//
//  Created by Yaroslav Bondar on 06.02.17.
//  Copyright © 2017 Yaroslav Bondar. All rights reserved.
//

import Foundation

protocol AuthorizationURLs {
    var baseUrl: URL { get }
    var refreshAccessToken: URL { get }
}

final class AuthorizationURLsImp: AuthorizationURLs {
    let baseUrl = RouteRequests.baseUrl
    let refreshAccessToken = RouteRequests.baseUrl +/ RouteRequests.authificationByRememberMe
}
