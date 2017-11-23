//
//  ServerError.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/10/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

final class ServerError {
    let code: Int
    var text: String?
    init(code: Int, data: Data?) {
        self.code = code
        if let data = data {
            text = String(data: data, encoding: .utf8)
        }
    }
}

extension ServerError: LocalizedError {
    var errorDescription: String? {
        if let text = text {
            if text == "Upload exceeds quota." {
                return "Not enough space in Lifebox"
            }
            return text
        }
        return "Code: \(code)"
    }
}
