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
    
    let fileListUrl = "https://adepo.turkcell.com.tr/api/filesystem?parentFolderUuid=%@&sortBy=%@&sortOrder=%@&page=%d&size=%d"
    
    //DataRequest
    func getFiles(folderUUID: String, page: Int, handler: @escaping ResponseHandler<String>) {
        
        let url = String(format: fileListUrl, folderUUID, "name", "ASC", page, 100)
        
//        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [request addValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        sessionManager
            .request(url)
            .customValidate()
            .responseData { response in
                debugPrint(response)
                switch response.result {
                case .success(let data):
                    
                    break
//                    if let json = json as? [String: String], let path = json["value"] {
//                        handler(ResponseResult.success(path))
//                    } else {
//                        let error = CustomErrors.text("Server error: \(json)")
//                        handler(ResponseResult.failed(error))
//                    }
                case .failure(let error):
                    handler(ResponseResult.failed(error))
                }
        }
    }
}
