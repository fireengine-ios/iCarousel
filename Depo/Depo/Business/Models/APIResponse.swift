//
//  APIResponse.swift
//  Depo
//
//  Created by Hady on 7/2/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

/// Base response for endpoints returning dict with `{"status": "", value: some}`
@dynamicMemberLookup struct APIResponse<Value: Codable>: Codable {
    let status: String
    let value: Value

    subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        value[keyPath: keyPath]
    }
}
