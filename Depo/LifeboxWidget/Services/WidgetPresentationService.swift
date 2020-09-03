//
//  WidgetPresentationService.swift
//  LifeboxWidgetExtension
//
//  Created by Roman Harhun on 03/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import CoreGraphics
import Alamofire

class UserInfo {
    var isFIREnabled: Bool = false
    var isPremiumUser: Bool = false
}

final class WidgetPresentationService {
    static let shared = WidgetPresentationService()
    
    var isAuthorized: Bool { serverService.isAuthorized }

    private let serverService = WidgetServerService(
        tokenStorage: TokenKeychainStorage(),
        sessionManager: SessionManager.customDefault
    )

    func getStorageQuota(completion: @escaping ((Int) -> ()), fail: @escaping VoidHandler) {
        serverService.getQuotaInfo { response in
            switch response {
            case .success(let quota):
                guard
                    let quotaBytes = quota.bytes,
                    let usedBytes = quota.bytesUsed
                else {
                    fail()
                    return
                }
                let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
                completion(Int(usagePercentage * 100))
            case .failed:
                fail()
            }
        }
    }
    
    func getDeviceStorageQuota(completion: @escaping ((Int) -> ())){
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
            let usedPersentage: CGFloat
            if let capacity = values.volumeAvailableCapacityForImportantUsage, let total = values.volumeTotalCapacity {
                usedPersentage = CGFloat(capacity) / CGFloat(total)
            } else {
                usedPersentage = .zero
            }
            completion(100 - (Int(usedPersentage * 100)))
        } catch {
            completion(.zero)
        }
    }
    
    func getContactBackupStatus(completion: @escaping ((ContantBackupResponse) -> ()), fail: @escaping VoidHandler) {
        serverService.getBackUpStatus(completion: completion, fail: fail)
    }
    
    func getPremiumStatus(completion: @escaping ((UserInfo) -> ())) {
        let premuimDate = UserInfo()
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        group.notify(queue: .main) {
            completion(premuimDate)
        }

        getFaceImageAllowance { face in
            premuimDate.isFIREnabled = face
            group.leave()
        }
        
        getPremuimStatus { premium in
            premuimDate.isPremiumUser = premium
            group.leave()
        }
    }
    
    private func getFaceImageAllowance(completion: @escaping ((Bool) -> ())) {
        serverService.getSettingsInfoPermissions { response in
            switch response {
            case .success(let response):
                completion(response.isFaceImageAllowed == true)
            case .failed:
                completion(false)
            }
        }
    }
    
    private func getPremuimStatus(completion: @escaping ((Bool) -> ())) {
        serverService.permissions { response in
            switch response {
            case .success(let response):
                completion(response.hasPermissionFor(.premiumUser))
            case .failed:
                completion(false)
            }
        }
    }
}
