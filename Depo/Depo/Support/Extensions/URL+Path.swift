//
//  URL+Path.swift
//  iGuru
//
//  Created by Yaroslav Bondar on 07.02.17.
//  Copyright © 2017 Yaroslav Bondar. All rights reserved.
//

import Foundation

infix operator +/

extension URL {
    static func +/ (lhs: URL, rhs: String) -> URL {
        return lhs.appendingPathComponent(rhs)
    }

    static func encodingURL(string: String, relativeTo url: URL?) -> URL? {
        var result = URL(string: string, relativeTo: url)
        if result == nil, let params = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            result = URL(string: params, relativeTo: url)
        }
        return result
    }
}

extension URL    {
    func checkFileExist() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            return true
        } else {
            return false
        }
    }
}
