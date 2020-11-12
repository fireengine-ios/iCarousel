//
//  PrivateShareApiResponses.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

struct SuggestedApiContact: Codable {
    let type: String?
    let identifier: String?
    let username: String?
    let email: String?
    let name: String?
    let picture: URL?
    
    static func testContacts() -> [SuggestedApiContact] {
        var contacts = [SuggestedApiContact]()
        
        let phones = ["8885555512", "5555228243", "5556106679", "5557664823", "5555648583"]
        
        for index in 1...5 {
            contacts.append(SuggestedApiContact(type: "USER",
                                                identifier: "user_\(index)",
                                                username: phones[index-1],
                                                email: "email_\(index)@gmail.com",
                                                name: "user_\(index)",
                                                picture: nil))
        }
        return contacts
    }
}


struct SharedFileInfo: Codable {
    let createdDateValue: Double?
    let lastModifiedDateValue: Double?
    let id: Int64
    let hash: String?
    let name: String?
    let uuid: String
    let bytes: Int64?
    let folder: Bool?
    let childCount: Int64?
    let status: String? // enum
    let uploaderDeviceType: String? //enum
    let ugglaId: String?
    let content_type: String?
    //        "metadata": {},
    let album: [String]?
    //        "location": {},
    let permissions: SharedItemPermission?
    let sharedBy: [SuggestedApiContact]?
    
    var creationDate: Date {
        guard let timeInterval = createdDateValue else {
            return Date()
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    var lastModifiedDate: Date {
        guard let timeInterval = lastModifiedDateValue else {
            return Date()
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    var fileType: FileType {
        return FileType(type: content_type, fileName: name)
    }
    
    enum CodingKeys: String, CodingKey {
        case createdDateValue = "createdDate"
        case lastModifiedDateValue = "lastModifiedDate"
        
        case id, hash, name, uuid, bytes, folder, childCount, status, uploaderDeviceType, ugglaId, content_type, album, permissions, sharedBy
    }
}


struct SharedItemPermission: Codable {
    let granted: [String]?
    let bitmask: Int64?
}


struct PrivateShareObject: Encodable {
    let items: [String]
    let invitationMessage: String?
    var invitees: [PrivateShareContact]
    let type: PrivateShareItemType
    let duration: PrivateShareDuration
    
    var parameters: [String: Any] {
        dictionary
    }
}

struct PrivateShareContact: Equatable, Encodable {
    let displayName: String
    let username: String
    var role: PrivateShareUserRole
    
    static func == (lhs: PrivateShareContact, rhs: PrivateShareContact) -> Bool {
        return lhs.username == rhs.username
    }
    
    enum CodingKeys: String, CodingKey {
        case username, role
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(role.rawValue, forKey: .role)
    }
}

enum PrivateShareUserRole: String, CaseIterable, Encodable {
    case editor = "EDITOR"
    case viewer = "VIEWER"
    
    var title: String {
        switch self {
        case .editor:
            return TextConstants.privateShareStartPageEditorButton
        case .viewer:
            return TextConstants.privateShareStartPageViewerButton
        }
    }
    
    var selectionTitle: String {
        switch self {
        case .editor:
            return TextConstants.privateShareRoleSelectionEditor
        case .viewer:
            return TextConstants.privateShareRoleSelectionViewer
        }
    }
}

enum PrivateShareItemType: String, Encodable {
    case file = "FILE"
    case album = "ALBUM"
}

enum PrivateShareDuration: String, CaseIterable, Encodable {
    case no = "NO_EXPIRE"
    case hour = "ONE_HOUR"
    case day = "ONE_DAY"
    case week = "ONE_WEEK"
    case month = "ONE_MONTH"
    case year = "ONE_YEAR"
    
    var title: String {
        switch self {
        case .no:
            return TextConstants.privateShareStartPageDurationNo
        case .hour:
            return TextConstants.privateShareStartPageDurationHour
        case .day:
            return TextConstants.privateShareStartPageDurationDay
        case .week:
            return TextConstants.privateShareStartPageDurationWeek
        case .month:
            return TextConstants.privateShareStartPageDurationMonth
        case .year:
            return TextConstants.privateShareStartPageDurationYear
        }
    }
}
