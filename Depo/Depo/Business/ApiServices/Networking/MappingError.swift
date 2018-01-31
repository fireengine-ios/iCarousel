//
//  MappingError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class MappingError {
    let jsonString: String
    init(data: Data) {
        jsonString = String(data: data, encoding: .utf8) ?? "Server error"
    }
}
extension MappingError: LocalizedError {
    var errorDescription: String? {
        return jsonString
    }
}
