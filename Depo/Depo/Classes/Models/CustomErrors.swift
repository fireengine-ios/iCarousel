//
//  CustomErrors.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

enum CustomErrors {
    case unknown
    case text(String)
}
extension CustomErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        case .text(let str):
            return str
        }
    }
}
