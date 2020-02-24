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
    
    var chunkSize: Int { get }
}


final class ResumableUploadInfoServiceImpl: ResumableUploadInfoService {
    private let session = SessionManager.customDefault
    private let userDefaults: StorageVars = factory.resolve()
    
    private lazy var accountService = AccountService()
    

    func updateInfo(handler: @escaping VoidHandler) {
        debugLog("update resumable upload info")
        
        accountService.getFeatures { [weak self] result in
            let currentUploadIsEnabled = self?.userDefaults.isResumableUploadEnabled
            let currentChunkSize = self?.userDefaults.resumableUploadChunkSize
          
            switch result {
            case .success(let response):
                self?.userDefaults.isResumableUploadEnabled = response.isResumableUploadEnabled ?? currentUploadIsEnabled
                self?.userDefaults.resumableUploadChunkSize = response.resumableUploadChunkSize ?? currentChunkSize
                
            case .failed(let error):
                debugLog(error.description)
                /// error is silenced
            }
            
            handler()
        }
    }
    
    func isResumableUploadAllowed(with fileSize: Int) -> Bool {
        // FIXME: remove guard
        guard RouteRequests.currentServerEnvironment != .production else {
            return false
        }
        return isUploadEnabled && fileSize > chunkSize
    }
}


// MARK: - User Defaults

extension ResumableUploadInfoServiceImpl {
    private var isUploadEnabled: Bool {
        return userDefaults.isResumableUploadEnabled ?? true
    }
    
    var chunkSize: Int {
        return userDefaults.resumableUploadChunkSize ?? NumericConstants.defaultResumableUploadChunkSize
    }
    
    func getInterruptedId(for trimmedLocalId: String) -> String? {
        let interruptedId = userDefaults.interruptedResumableUploads[trimmedLocalId] as? String
        debugLog("resumable_upload: get \(interruptedId ?? "_EMPTY_") as interruptedId for \(trimmedLocalId)")
        return interruptedId
    }
    
    func save(interruptedId: String, for trimmedLocalId: String) {
        debugLog("resumable_upload: saving \(interruptedId) as interruptedId for \(trimmedLocalId)")
        userDefaults.interruptedResumableUploads[trimmedLocalId] = interruptedId
    }
    
    func removeInterruptedId(for trimmedLocalId: String) {
        debugLog("resumable_upload: removing interruptedId for \(trimmedLocalId)")
        userDefaults.interruptedResumableUploads[trimmedLocalId] = nil
    }
}
