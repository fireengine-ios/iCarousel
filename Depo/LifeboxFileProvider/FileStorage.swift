//
//  FileStorage.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import FileProvider

final class FileStorage {
    
    static let shared = FileStorage()
    
    let fileManager = FileManager.default
    
    func write(_ item: NSFileProviderItem) {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent(item.itemIdentifier.rawValue)
            NSKeyedArchiver.archiveRootObject(item, toFile: fileURL.path)
        } catch {
            print(error)
        }
    }
    
    func read(for itemIdentifier: NSFileProviderItemIdentifier) throws -> FileProviderItem {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent(itemIdentifier.rawValue)
            if let item = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? FileProviderItem {
                return item
            }
            throw unknownError
            
        } catch {
            throw error
        }
    }
}
