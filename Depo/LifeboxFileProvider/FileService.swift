//
//  FileService.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/2/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class FileService {
    
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = factory.resolve()) {
        self.sessionManager = sessionManager
        ShareConfigurator().setup()
    }
    
    private let fileListUrl = RouteRequests.baseUrl.absoluteString + "filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    
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
                    if !folderUUID.isEmpty {
                        array.forEach { $0.parentItemIdentifier = NSFileProviderItemIdentifier(rawValue: folderUUID) }
                    }
                    handler(ResponseResult.success(array))
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
}
