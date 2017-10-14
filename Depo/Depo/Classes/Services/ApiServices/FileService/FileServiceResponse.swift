//
//  FilesListResponse.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class FileListResponse: ObjectRequestResponse {
    
    var parentFolderName: String?
    var parentFolderList = [String]()
    var fileList = [WrapData]()
    
    override func mapping() {
        parentFolderName = json?["parentFolderName"].string
//        parentFolderList = //
        guard let list = json?["fileList"].array else {
            return
        }
        fileList = list.flatMap{ WrapData(remote: SearchItemResponse(withJSON: $0) ) }
    }
}
