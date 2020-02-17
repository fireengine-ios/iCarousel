//
//  ResumableUploadInfoService.swift
//  Depo
//
//  Created by Konstantin Studilin on 17/02/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Alamofire


protocol ResumableUploadInfoService {
    func updateInfo(handler: @escaping VoidHandler)
}


final class ResumableUploadInfoServiceImpl: ResumableUploadInfoService {
    private let session = SessionManager.customDefault
    private let defaults: StorageVars = factory.resolve()
    
    private lazy var accountService = AccountService()
    
    var isUploadEnabled: Bool {
        return defaults.isResumableUploadEnabled ?? true
    }
    
    var chunkSize: Int {
        return defaults.resumableUploadChunkSize ?? NumericConstants.defaultResumableUploadChunkSize
    }
    
    func updateInfo(handler: @escaping VoidHandler) {
        debugLog("update resumable upload info")
        
        accountService.getFeatures { [weak self] result in
            let currentUploadIsEnabled = self?.defaults.isResumableUploadEnabled
            let currentChunkSize = self?.defaults.resumableUploadChunkSize
          
            switch result {
            case .success(let response):
                self?.defaults.isResumableUploadEnabled = response.isResmableUploadEnabled ?? currentUploadIsEnabled
                self?.defaults.resumableUploadChunkSize = response.resumableUploadChunkSize ?? currentChunkSize
                
            case .failed(let error):
                debugLog(error.description)
                /// error is silenced
            }
            
            handler()
        }
    }
}
