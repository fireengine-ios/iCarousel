//
//  FileManager+Size.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

extension FileManager {
    func fileSize(at url: URL) -> Int64? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.size] as? Int64
    }
    
    func creationDate(at url: URL) -> Date? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.creationDate] as? Date
    }
    
    func fileType(at url: URL) -> String? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.type] as? String
    }
}
