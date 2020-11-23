//
//  PrivateShareApiResponses.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

struct SuggestedApiContact: Codable {
    let type: PrivateShareSubjectType?
    let identifier: String?
    let username: String?
    let email: String?
    var name: String?
    let picture: URL?
}

struct SharedFileInfo: Codable {
    let createdDate: Date?
    let lastModifiedDate: Date?
    let id: Int64
    let projectId: String?
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
    let album: [FileAlbum]?
    //        "location": {},
    let permissions: SharedItemPermission?
    let sharedBy: [SuggestedApiContact]?
    var members: [SharedContact]?
    
    
    var fileType: FileType {
        return FileType(type: content_type, fileName: name)
    }
}

struct UrlToDownload: Codable {
    let url: URL?
}

struct FileAlbum: Codable {
    
}

struct FileSystem: Codable {
    let parentFolderList: [SharedFileInfo]
    let fileList: [SharedFileInfo]
}


struct SharedItemPermission: Codable {
    let granted: [PrivateSharePermission]?
    let bitmask: Int64?
}

struct PrivateShareObjectItem: Encodable {
    let projectId: String
    let uuid: String
}


struct PrivateShareObject: Encodable {
    let items: [PrivateShareObjectItem]
    let invitationMessage: String?
    var invitees: [PrivateShareContact]
    let type: PrivateShareItemType
    let duration: PrivateShareDuration
    
    var parameters: [String: Any] {
        dictionary
    }
}

//model for requests
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

enum PrivateShareUserRole: String, CaseIterable, Codable {
    case editor = "EDITOR"
    case viewer = "VIEWER"
    case owner = "OWNER"
    
    var title: String {
        switch self {
        case .editor:
            return TextConstants.privateShareStartPageEditorButton
        case .viewer:
            return TextConstants.privateShareStartPageViewerButton
        case .owner:
            return ""
        }
    }
    
    var selectionTitle: String {
        switch self {
        case .editor:
            return TextConstants.privateShareRoleSelectionEditor
        case .viewer:
            return TextConstants.privateShareRoleSelectionViewer
        case .owner:
            return ""
        }
    }
    
    var infoMenuTitle: String {
        switch self {
        case .editor:
            return TextConstants.privateShareInfoMenuEditor
        case .viewer:
            return TextConstants.privateShareInfoMenuViewer
        case .owner:
            return TextConstants.privateShareInfoMenuOwner
        }
    }
    
    var whoHasAccessTitle: String {
        switch self {
        case .editor:
            return TextConstants.privateShareWhoHasAccessEditor
        case .viewer:
            return TextConstants.privateShareWhoHasAccessViewer
        case .owner:
            return TextConstants.privateShareWhoHasAccessOwner
        }
    }
    
    var order: Int {
        switch self {
        case .owner:
            return 0
        case .editor:
            return 1
        case .viewer:
            return 2
        }
    }
}

enum PrivateShareItemType: String, Codable {
    case file = "FILE"
    case album = "ALBUM"
}

enum PrivateShareDuration: String, CaseIterable, Codable {
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

enum PrivateShareSubjectType: String, Codable {
    case user = "USER"
    case group = "USER_GROUP"
    case knownName = "KNOWN_NAME"
}

struct SharedContact: Codable, Equatable {
    var subject: SuggestedApiContact?
    let permissions: SharedItemPermission?
    let role: PrivateShareUserRole
    
    var displayName: String {
        subject?.name ?? subject?.username ?? ""
    }
    
    var initials: String {
        if let name = subject?.name {
            let characters = name.split(separator: " ").prefix(2).compactMap { $0.first }
            return characters.map { String($0) }.joined().uppercased()
        } else {
            return ""
        }
    }
    
    static func == (lhs: SharedContact, rhs: SharedContact) -> Bool {
        if let lusername = lhs.subject?.username, let rusername = rhs.subject?.username {
            return lusername == rusername
        }
        return lhs.subject?.email == rhs.subject?.email
    }
    
    func color(for index: Int) -> UIColor? {
        switch index.remainderReportingOverflow(dividingBy: 6).partialValue {
        case 0:
            return .lrTealishTwo
        case 1:
            return ColorConstants.marineFour
        case 2:
            return .lrDarkSkyBlue
        case 3:
            return .lrOrange
        case 4:
            return .lrButterScotch
        case 5:
            return .lrFadedRed
        default:
            return nil
        }
    }
}

enum PrivateSharePermission: String, Codable {
    case read = "READ"
    case preview = "PREVIEW"
    case list = "LIST"
    case create = "CREATE"
    case delete = "DELETE"
    case setAttribute = "SET_ATTRIBUTE"
    case update = "UPDATE"
    case comment = "COMMENT"
    case writeAcl = "WRITE_ACL"
    case readAcl = "READ_ACL"
}

struct PrivateShareAccessListObject: Codable {
    let type: PrivateShareItemType
    let uuid: String
    let name: String
}

enum PrivateShareAccessListType: String, Codable {
    case allow = "ALLOW"
    case deny = "DENY"
}

struct PrivateShareAccessListInfo: Codable {
    let id: Int64
    let type: PrivateShareAccessListType
    let object: PrivateShareAccessListObject
    let subject: SuggestedApiContact
    let permissions: SharedItemPermission
    let role: PrivateShareUserRole
    let expirationDate: Date
    let conditions: [String]? //unknown array type
}

struct PrivateSharePermissionList: Codable {
    let permissions: SharedItemPermission?
    let role: PrivateShareUserRole
}
