//
//  FileManager.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/6/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FileManager {
    
    static let shared = FileManager()
    
    /// need to test:
    /// can one NSFileCoordinator coordinate some urls?
    /// put NSFileCoordinator() in property
    func waitFilePreparation(at url: URL, complition: ResponseVoid) {
        var fcError: NSError? 
        
        NSFileCoordinator().coordinate(readingItemAt: url, options: .forUploading, error: &fcError) { _ in
            if let error = fcError {
                complition(ResponseResult.failed(error))
            } else {
                complition(ResponseResult.success(()))
            }
        }
    }
}
