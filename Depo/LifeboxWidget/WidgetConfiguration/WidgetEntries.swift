//
//  WidgetEntry.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit

class WidgetBaseEntry: TimelineEntry, Codable {
    let date: Date
    init(date: Date) {
        self.date = date
    }
}

final class WidgetLoginRequiredEntry: WidgetBaseEntry { }

final class WidgetQuotaEntry: WidgetBaseEntry {
    private(set) var usedPercentage: Int
    
    init(usedPercentage: Int, date: Date) {
        self.usedPercentage = usedPercentage
        super.init(date: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case date, usedPercentage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        usedPercentage = try container.decodeIfPresent(Int.self, forKey: .usedPercentage) ?? 0
        try super.init(from: decoder)
    }
}

final class WidgetDeviceQuotaEntry: WidgetBaseEntry {
    private(set) var usedPercentage: Int
    
    init(usedPercentage: Int, date: Date) {
        self.usedPercentage = usedPercentage
        super.init(date: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case usedPercentage
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        usedPercentage = try container.decodeIfPresent(Int.self, forKey: .usedPercentage) ?? 0
        try super.init(from: decoder)
    }
}

final class WidgetContactBackupEntry: WidgetBaseEntry {
    private(set) var backupDate: Date?
    
    init(backupDate: Date? = nil, date: Date) {
        self.backupDate = backupDate
        super.init(date: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case backupDate
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backupDate = try container.decodeIfPresent(Date.self, forKey: .backupDate) ?? Date()
        try super.init(from: decoder)
    }
}

final class WidgetUserInfoEntry: WidgetBaseEntry {
    private(set) var isFIREnabled: Bool
    private(set) var hasFIRPermission: Bool
    private(set) var peopleInfos: [PeopleInfo]
    private(set) var images = [UIImage]()
       
    var lessThen3Images: Bool {
        isFIREnabled && hasFIRPermission && peopleInfos.count < 3
    }
    
    init(isFIREnabled: Bool, hasFIRPermission: Bool, peopleInfos: [PeopleInfo], date: Date) {
        self.isFIREnabled = isFIREnabled
        self.hasFIRPermission = hasFIRPermission
        self.peopleInfos = peopleInfos
        super.init(date: date)
        
        setupImages()
    }
    
    enum CodingKeys: String, CodingKey {
        case isFIREnabled, hasFIRPermission, peopleInfos, imagePaths
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isFIREnabled = try container.decodeIfPresent(Bool.self, forKey: .isFIREnabled) ?? false
        hasFIRPermission = try container.decodeIfPresent(Bool.self, forKey: .hasFIRPermission) ?? false
        peopleInfos = try container.decodeIfPresent([PeopleInfo].self, forKey: .peopleInfos) ?? []
        try super.init(from: decoder)
        setupImages()
    }
    
    private func setupImages() {
        guard !peopleInfos.isEmpty else {
            images = [UIImage(named: "user-3")!, UIImage(named: "user-2")!, UIImage(named: "user-1")!]
            return
        }
        
        let cache = WidgetImageCache.shared
        let urls = peopleInfos.map { $0.thumbnail ?? $0.alternateThumbnail }
        
        images = urls.enumerated().map { index, url -> UIImage in
            if let url = url, let image = cache[url] {
                return image
            }
            
            switch index {
            case 0:
                return UIImage(named: "user-3")!
            case 1:
                return UIImage(named: "user-2")!
            case 2:
                if lessThen3Images {
                    return UIImage(named: "plusIcon")!
                } else {
                    return UIImage(named: "user-1")!
                }
            default:
                return UIImage(named: "user-3")!
            }
        }
    }
}

final class WidgetAutoSyncEntry: WidgetBaseEntry {
    private(set) var isSyncEnabled: Bool
    private(set) var isAppLaunched: Bool
    
    init(isSyncEnabled: Bool, isAppLaunched: Bool, date: Date) {
        self.isSyncEnabled = isSyncEnabled
        self.isAppLaunched = isAppLaunched
        
        super.init(date: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case isSyncEnabled, isAppLaunched
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSyncEnabled = try container.decodeIfPresent(Bool.self, forKey: .isSyncEnabled) ?? false
        isAppLaunched = try container.decodeIfPresent(Bool.self, forKey: .isAppLaunched) ?? false
        try super.init(from: decoder)
    }
}

final class WidgetSyncInProgressEntry: WidgetBaseEntry {
    private(set) var uploadCount: Int
    private(set) var totalCount: Int
    private(set) var currentFileName: String
    
    var isSyncComplete: Bool {
        uploadCount == totalCount
    }
    
    init(uploadCount: Int, totalCount: Int, currentFileName: String, date: Date) {
        self.uploadCount = uploadCount
        self.totalCount = totalCount
        self.currentFileName = currentFileName
        
        super.init(date: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case uploadCount, totalCount, currentFileName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uploadCount = try container.decodeIfPresent(Int.self, forKey: .uploadCount) ?? 0
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        currentFileName = try container.decodeIfPresent(String.self, forKey: .currentFileName) ?? ""
        try super.init(from: decoder)
    }
}

//MARK: -

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}
