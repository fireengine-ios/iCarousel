//
//  WidgetPresentationService.swift
//  LifeboxWidgetExtension
//
//  Created by Roman Harhun on 03/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import CoreGraphics

class UserInfo {
    var isFIREnabled = false
    var isPremiumUser = false
    var images = [UIImage?]()
}

final class WidgetPresentationService {
    static let shared = WidgetPresentationService()
    
    var isAuthorized: Bool { serverService.isAuthorized }

    private let serverService = WidgetServerService.shared
    private let photoLibraryService = WidgetPhotoLibraryObserver.shared

    func getStorageQuota(completion: @escaping ValueHandler<Int>, fail: @escaping VoidHandler) {
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
    
    func getDeviceStorageQuota(completion: @escaping ValueHandler<Int>){
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
    
    func getContactBackupStatus(completion: @escaping ValueHandler<ContantBackupResponse>, fail: @escaping VoidHandler) {
        serverService.getBackUpStatus(completion: completion, fail: fail)
    }
    
    func getPremiumStatus(completion: @escaping ValueHandler<UserInfo>) {
        let userInfo = UserInfo()
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        group.notify(queue: .main) { [weak self] in
            if userInfo.isPremiumUser && userInfo.isFIREnabled {
                self?.getPeopleInfo { [weak self] peopleInfos in
                    self?.loadImages(completion: { images in
                        userInfo.images = images
                        completion(userInfo)
                    })
                }
            } else {
                //show only placeholders
                userInfo.images = [nil, nil, nil]
                completion(userInfo)
            }
            
        }

        getFaceImageAllowance { face in
            userInfo.isFIREnabled = face
            group.leave()
        }
        
        getPremuimStatus { premium in
            userInfo.isPremiumUser = premium
            group.leave()
        }
    }
    
    func hasUnsyncedItems(completion: @escaping (Bool) -> ()) {
        photoLibraryService.hasUnsynced(completion: completion)
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
    
    private func getPremuimStatus(completion: @escaping BoolHandler) {
        serverService.permissions { response in
            switch response {
            case .success(let response):
                completion(response.hasPermissionFor(.premiumUser))
            case .failed:
                completion(false)
            }
        }
    }
    
    private func getPeopleInfo(completion: @escaping ValueHandler<[PeopleInfo]>) {
        serverService.getPeopleInfo { result in
            switch result {
            case .success(let response):
                completion(response.personInfos)
            case .failed:
                completion([])
            }
        }
    }
    
    private func loadImages(completion: @escaping ValueHandler<[UIImage?]>) {
        getPeopleInfo { peopleInfos in
            let urls = peopleInfos.map { $0.thumbnail ?? $0.alternateThumbnail }
            WidgetImageLoader().loadImage(urls: urls, completion: completion)
        }
    }
}
