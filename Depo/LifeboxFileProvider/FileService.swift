//
//  FileService.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/2/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class FileStorage {
    
    static let shared = FileStorage()
    
    let fileManager = FileManager.default
    
    func write(_ item: FileProviderItem) {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(item.itemIdentifier.rawValue)
            NSKeyedArchiver.archiveRootObject(item, toFile: fileURL.path)
        } catch {
            print(error)
        }
        
    }
    
    func read(for itemIdentifier: NSFileProviderItemIdentifier) -> FileProviderItem {
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(itemIdentifier.rawValue)
            let item = NSKeyedUnarchiver.unarchiveObject(withFile: fileURL.path) as? FileProviderItem
            return item ?? FileProviderItem()
            
        } catch {
            print(error)
            return FileProviderItem()
        }
    }
}

final class FileService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
        ShareConfigurator().setup()
    }
    
    let fileListUrl = "https://adepo.turkcell.com.tr/api/filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    
    //DataRequest
    func getFiles(folderUUID: String, page: Int, handler: @escaping ResponseHandler<[FileProviderItem]>) {
        
        let url = String(format: fileListUrl, folderUUID, "name", "ASC", page, 100)
        
        sessionManager
            .request(url)
            .customValidate()
            
            .responseData { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    let array = FileProviderItem.array(from: data)
                    handler(ResponseResult.success(array))
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
}
