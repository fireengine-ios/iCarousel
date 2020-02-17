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
    
    
    func updateInfo(handler: @escaping VoidHandler) {
        debugLog("update resumable upload info")
        
        accountService.getFeatures { [weak self] result in
            let currentUploadIsEnabled = self?.defaults.isResumableUploadEnabled
            let currentChunkSize = self?.defaults.resumableUploadChunkSize
          
            var updatedUploadIsEnabled: Bool?
            var updatedChunkSize: Int?
            
            switch result {
            case .success(let response):
                updatedUploadIsEnabled = response.isResmableUploadEnabled
                updatedChunkSize = response.resumableUploadChunkSize
                
            case .failed(let error):
                debugLog(error.description)
                /// error is silenced
            }
            
            self?.defaults.isResumableUploadEnabled = updatedUploadIsEnabled ?? currentUploadIsEnabled ?? true
            self?.defaults.resumableUploadChunkSize = updatedChunkSize ?? currentChunkSize ?? NumericConstants.defaultResumableUploadChunkSize
            
            handler()
        }
    }
}
