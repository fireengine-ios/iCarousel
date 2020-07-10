//
//  ResumableUploadInfoService.swift
//  Depo
//
//  Created by Konstantin Studilin on 05/03/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Alamofire


final class ResumableUploadInfoService {
    static let shared = ResumableUploadInfoService()
    
    private let userDefaultsService = UserDefaultsService.shared
    private let sessionManager: SessionManager = factory.resolve()
    private let accountInfo = AccountInfoService.shared
    
    
    private init() {}
    
    
    func updateInfo(handler: @escaping VoidHandler) {
        self.accountInfo.updateAccountInfo { [weak self] isUpdated in
            guard isUpdated else {
                handler()
                return
            }
            
            self?.sessionManager
                .request(RouteRequests.Account.Permissions.features)
                .customValidate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        if let json = json as? [String: Any] {
                            let currentUploadIsEnabled = self?.userDefaultsService.isResumableUploadEnabled
                            let currentChunkSize = self?.userDefaultsService.resumableUploadChunkSize
                            
                            let newUploadIsEnabled = json["resumable-upload-enabled"] as? Bool
                            let newChunkSize = json["resumable-upload-chunk-size-in-bytes"] as? Int
                            
                            self?.userDefaultsService.isResumableUploadEnabled = newUploadIsEnabled ?? currentUploadIsEnabled
                            self?.userDefaultsService.resumableUploadChunkSize = newChunkSize ?? currentChunkSize
                        }
                        
                        handler()
                        
                    case .failure(_):
                        // silence an error
                        handler()
                        return
                    }
            }
        }
    }
    
    func isResumableUploadAllowed(with fileSize: Int64) -> Bool {
        return isUploadEnabled && fileSize > chunkSize
    }
}

// MARK: - User Defaults

extension ResumableUploadInfoService {
    private var isUploadEnabled: Bool {
        return userDefaultsService.isResumableUploadEnabled ?? true
    }
    
    var chunkSize: Int {
        return userDefaultsService.resumableUploadChunkSize ?? NumericConstants.defaultResumableUploadChunkSize
    }
    
    func getInterruptedId(for key: String) -> String? {
        return userDefaultsService.interruptedResumableUploads[key] as? String
    }
    
    func save(interruptedId: String, for key: String) {
        userDefaultsService.interruptedResumableUploads[key] = interruptedId
    }
    
    func removeInterruptedId(for key: String) {
        userDefaultsService.interruptedResumableUploads[key] = nil
    }
}

