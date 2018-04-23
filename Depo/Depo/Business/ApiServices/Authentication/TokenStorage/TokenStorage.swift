//
//  TokenStorage.swift
//  NetworingAuth
//
//  Created by Yaroslav Bondar on 06.02.17.
//  Copyright © 2017 Yaroslav Bondar. All rights reserved.
//

import Foundation

protocol TokenStorage: class {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var isRememberMe: Bool { get set }
    var isClearTokens: Bool { get set }
    func clearTokens()
}
