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
    func isResumableUploadAllowed(with fileSize: Int) -> Bool
    
    func getInterruptedId(for trimmedLocalId: String) -> String?
    func save(interruptedId:String, for trimmedLocalId: String)
    func removeInterruptedId(for trimmedLocalId: String)
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
    
    func isResumableUploadAllowed(with fileSize: Int) -> Bool {
        return isUploadEnabled && fileSize > chunkSize
    }
}


// MARK: - Defaults

extension ResumableUploadInfoServiceImpl {
    private var isUploadEnabled: Bool {
        return defaults.isResumableUploadEnabled ?? true
    }
    
    private var chunkSize: Int {
        return defaults.resumableUploadChunkSize ?? NumericConstants.defaultResumableUploadChunkSize
    }
    
    func getInterruptedId(for trimmedLocalId: String) -> String? {
        return defaults.interruptedResumableUploads[trimmedLocalId] as? String
    }
    
    func save(interruptedId:String, for trimmedLocalId: String) {
        defaults.interruptedResumableUploads[trimmedLocalId] = interruptedId
    }
    
    func removeInterruptedId(for trimmedLocalId: String) {
        defaults.interruptedResumableUploads[trimmedLocalId] = nil
    }
}
