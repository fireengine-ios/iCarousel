//
//  UserDefaultsService.swift
//  Depo
//
//  Created by Konstantin Studilin on 06/03/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


final class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let userDefaults = UserDefaults.standard
    private let accountInfo = AccountInfoService.shared
    
    
    private init() {}
    
    
    private let interruptedResumableUploadsKey = "interruptedResumableUploads"
    var interruptedResumableUploads: [String : Any] {
        get { return userDefaults.dictionary(forKey: interruptedResumableUploadsKey + accountInfo.userId) ?? [:] }
        set { userDefaults.set(newValue, forKey: interruptedResumableUploadsKey + accountInfo.userId) }
    }
    
    private let isResumableUploadEnabledKey = "isResumableUploadEnabled"
    var isResumableUploadEnabled: Bool? {
        get { return userDefaults.value(forKey: isResumableUploadEnabledKey + accountInfo.userId) as? Bool }
        set { userDefaults.set(newValue, forKey: isResumableUploadEnabledKey + accountInfo.userId) }
    }
    
    private let resumableUploadChunkSizeKey = "resumableUploadChunkSize"
    var resumableUploadChunkSize: Int? {
        get { return userDefaults.value(forKey: resumableUploadChunkSizeKey + accountInfo.userId) as? Int }
        set { userDefaults.set(newValue, forKey: resumableUploadChunkSizeKey + accountInfo.userId) }
    }
}
