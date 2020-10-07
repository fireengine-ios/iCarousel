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

enum WidgetStateOrder: Int {
    case login
    case quota
    case freeUpSpace
    case syncComplete
    case syncInProgress
    case autosync
    case contactsNoBackup
    case oldContactsBackup
    case fir
    
    var score: Float {
        Float(100 - rawValue)
    }
    
    var duration: Double {
        switch self {
        case .syncComplete:
            return 5
        case .syncInProgress:
            //1 hour
            return 60 * 60
        default:
            //8 hours
            return 60 * 60 * 8
        }
    }
    
    var refreshDate: Date? {
        let currentDate = Date()
        switch self {
        case .login: //ORDER-0
            return nil
        case .quota, .freeUpSpace, .autosync, .contactsNoBackup, .oldContactsBackup, .fir:  //ORDER 1-2 //ORDER-4-7:
            let refreshDate: Date
            
            if Bundle.main.bundleIdentifier == "by.come.life.Lifebox" || Bundle.main.bundleIdentifier ==  "by.come.life.Lifebox.widget" {
                refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate) ?? currentDate
            } else {
                refreshDate = Calendar.current.date(byAdding: .hour, value: 8, to: currentDate) ?? currentDate
                
            }
             
            return  refreshDate
        case .syncInProgress, .syncComplete://ORDER-3-4
            let refreshDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate) ?? currentDate
            return refreshDate
        }
    }
    
    var relevance: TimelineEntryRelevance {
        return TimelineEntryRelevance(score: score, duration: duration)
    }
}

class WidgetBaseEntry: TimelineEntry, Codable {
    let date: Date
    let state: WidgetState
    init(date: Date, state: WidgetState) {
        self.date = date
        self.state = state
    }
    
    enum CodingKeys: String, CodingKey {
        case date, state
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        state = WidgetState(rawValue: try container.decodeIfPresent(Int.self, forKey: .state) ?? 0) ?? .login
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(state.rawValue, forKey: .state)
    }
}

final class WidgetLoginRequiredEntry: WidgetBaseEntry {
    init(date: Date) {
        super.init(date: date, state: .login)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

final class WidgetQuotaEntry: WidgetBaseEntry {
    private(set) var usedPercentage: Int
    
    init(usedPercentage: Int, date: Date) {
        self.usedPercentage = usedPercentage
        super.init(date: date, state: .quota)
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

final class WidgetDeviceQuotaEntry: WidgetBaseEntry {
    private(set) var usedPercentage: Int
    
    init(usedPercentage: Int, date: Date) {
        self.usedPercentage = usedPercentage
        super.init(date: date, state: .freeUpSpace)
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
    private var backupDate: Date?
    
    var monthSinceLastBackup: Int {
        guard let backupDate = backupDate else {
            return 0
        }
        
        let components = Calendar.current.dateComponents([.month], from: backupDate, to: Date())
        return components.month ?? 0
    }
    
    init(backupDate: Date? = nil, date: Date) {
        self.backupDate = backupDate
        super.init(date: date, state: backupDate == nil ? .contactsNoBackup : .contactsOldBackup)
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

final class WidgetUserInfoEntry: WidgetBaseEntry {
    private(set) var peopleInfos: [PeopleInfo]
    private(set) var images = [UIImage]()
    
    init(isFIREnabled: Bool, hasFIRPermission: Bool, peopleInfos: [PeopleInfo], date: Date) {
        self.peopleInfos = peopleInfos
        
        let state: WidgetState
        if !hasFIRPermission {
            state = .firStandart
        } else if !isFIREnabled {
            state = .firDisabled
        } else if peopleInfos.count < 3 {
            state = .firLess3People
        } else {
            state = .fir
        }

        super.init(date: date, state: state)
        
        setupImages()
    }
    
    enum CodingKeys: String, CodingKey {
        case isFIREnabled, hasFIRPermission, peopleInfos, imagePaths
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
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
                if state == .firLess3People {
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
    
    init(isSyncEnabled: Bool, date: Date) {
        super.init(date: date, state: isSyncEnabled ? .autosyncAppNotLaunch : .autosyncDisable)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

final class WidgetSyncInProgressEntry: WidgetBaseEntry {
    private(set) var uploadCount: Int
    private(set) var totalCount: Int
    private(set) var currentFileName: String
    
    init(isSyncCompleted: Bool = false, uploadCount: Int = 0, totalCount: Int = 0, currentFileName: String = "", date: Date) {
        self.uploadCount = uploadCount
        self.totalCount = totalCount
        self.currentFileName = currentFileName
        
        super.init(date: date, state: isSyncCompleted ? .syncComplete : .syncInProgress)
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

enum WidgetState: Int {
    case login = 0
    case quota
    case freeUpSpace
    case syncComplete
    case syncInProgress
    case autosyncDisable
    case autosyncAppNotLaunch
    case contactsNoBackup
    case contactsOldBackup
    case fir
    case firLess3People
    case firDisabled
    case firStandart
    
    var gaName: String {
        switch self {
        case .login:
            return "Logout"
        case .quota:
            return "Quota"
        case .freeUpSpace:
            return "Free Up Space"
        case .autosyncDisable, .autosyncAppNotLaunch:
            return "Unsynced Files"
        case .syncInProgress:
            return "Sync in Progress"
        case .syncComplete:
            return "Sync completed"
        case .contactsNoBackup:
            return "No back up"
        case .contactsOldBackup:
            return "Old back up"
        case .fir:
            return "Face Image - Prem and Enabled Faces"
        case .firLess3People:
            return "Face Image - Less than three faces"
        case .firDisabled:
            return "Face Image - Prem and Disabled Faces"
        case .firStandart:
            return "Face Image - Standard"
        }
    }
}
