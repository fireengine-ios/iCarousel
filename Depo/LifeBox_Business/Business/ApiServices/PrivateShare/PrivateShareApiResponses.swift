//
//  PrivateShareApiResponses.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SuggestedApiContact: Codable {
    let type: PrivateShareSubjectType?
    let identifier: String?
    let username: String?
    let email: String?
    var name: String?
    let picture: URL?
}

struct SharedFileInfo: Codable {
    let shared: Bool
    let createdDate: Date?
    let lastModifiedDate: Date?
    let id: Int64
    let accountUuid: String
    let hash: String?
    let name: String?
    let uuid: String
    let bytes: Int64?
    let folder: Bool?
    let childCount: Int64?
    let status: String? // enum
    let uploaderDeviceType: String? //enum
    let ugglaId: String?
    let contentType: String?
    let metadata: SharedFileInfoMetaData?
    let album: [FileAlbum]?
    //        "location": {},
    let permissions: SharedItemPermission?
    var members: [SharedContact]?
    
    
    var fileType: FileType {
        return FileType(type: contentType, fileName: name)
    }
}

struct SharedFileInfoMetaData: Codable {
    let isFavourite: Bool?
    
    let thumbnailLarge: URL?
    let thumbnailMedium: URL?
    let thumbnailSmall: URL?
    let videoPreview: URL?
    
    let originalHash: String?
    let originalBytes: Int64?
    
    let imageHeight: Int?
    let imageWidth: Int?
    let imageOrientation: Int? //enum?
    let imageDateTime: Date?
    
    let latitude: Double?
    let longitude: Double?
    
    let specialFolderMeta: String?
    
    private enum CodingKeys: String, CodingKey {
        case isFavourite = "X-Object-Meta-Favourite"
        case thumbnailLarge = "Thumbnail-Large"
        case thumbnailMedium = "Thumbnail-Medium"
        case thumbnailSmall = "Thumbnail-Small"
        case videoPreview = "Video-Preview"
        
        case originalHash = "X-Object-Meta-Ios-Metadata-Hash"
        case originalBytes = "Original-Bytes"
        
        case imageHeight = "Image-Height"
        case imageWidth = "Image-Width"
        case imageOrientation = "Image-Orientation"
        case imageDateTime = "Image-DateTime"
        
        case latitude = "Latitude"
        case longitude = "Longitude"
        case specialFolderMeta = "X-Object-Meta-Special-Folder"

    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        originalBytes = JSON(try container.decodeIfPresent(String.self, forKey: .originalBytes) ?? "").int64
        isFavourite = JSON(try container.decodeIfPresent(String.self, forKey: .isFavourite) ?? "").boolFromString
        
        thumbnailLarge = JSON(try container.decodeIfPresent(String.self, forKey: .thumbnailLarge) ?? "").url
        thumbnailMedium = JSON(try container.decodeIfPresent(String.self, forKey: .thumbnailMedium) ?? "").url
        thumbnailSmall = JSON(try container.decodeIfPresent(String.self, forKey: .thumbnailSmall) ?? "").url
        videoPreview = JSON(try container.decodeIfPresent(String.self, forKey: .videoPreview) ?? "").url
        
        originalHash = try container.decodeIfPresent(String.self, forKey: .originalHash)
        specialFolderMeta = try container.decodeIfPresent(String.self, forKey: .specialFolderMeta)
        
        imageHeight = JSON(try container.decodeIfPresent(String.self, forKey: .imageHeight) ?? "").int
        imageWidth = JSON(try container.decodeIfPresent(String.self, forKey: .imageWidth) ?? "").int
        imageOrientation = JSON(try container.decodeIfPresent(String.self, forKey: .imageOrientation) ?? "").int
        
        imageDateTime = JSON(try container.decodeIfPresent(String.self, forKey: .imageDateTime) ?? "").date
        
        latitude = JSON(try container.decodeIfPresent(String.self, forKey: .latitude) ?? "").double
        longitude = JSON(try container.decodeIfPresent(String.self, forKey: .longitude) ?? "").double
    }
}

struct WrappedUrl: Codable {
    let url: URL?
}

struct FileAlbum: Codable {
    
}

struct FileSystem: Codable {
    let parentFolderName: String
    let parentFolderList: [SharedFileInfo]
    let fileList: [SharedFileInfo]
}

struct SharedItemPermission: Codable, Equatable {
    let granted: [PrivateSharePermission]?
    let bitmask: Int64?
}

struct PrivateShareObjectItem: Encodable {
    let accountUuid: String
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
    
    var type: PrivateShareSubjectType
    var role: PrivateShareUserRole
    var identifier: String
    
    static func == (lhs: PrivateShareContact, rhs: PrivateShareContact) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    enum CodingKeys: String, CodingKey {
        case username, role, identifier, type
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(role.rawValue, forKey: .role)
        try container.encode(identifier, forKey: .identifier)
    }
}

enum PrivateShareUserRole: String, CaseIterable, Codable {
    case editor = "EDITOR"
    case viewer = "VIEWER"
    case owner = "OWNER"
    case varying = "VARYING"
    
    var title: String {
        switch self {
        case .editor:
            return TextConstants.privateShareStartPageEditorButton
        case .viewer:
            return TextConstants.privateShareStartPageViewerButton
        case .owner, .varying:
            return ""
        }
    }
    
    var selectionTitle: String {
        switch self {
        case .editor:
            return TextConstants.privateShareRoleSelectionEditor
        case .viewer:
            return TextConstants.privateShareRoleSelectionViewer
        case .owner, .varying:
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
        case .varying:
            return TextConstants.privateShareInfoMenuVarying
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
        case .varying:
            return TextConstants.privateShareWhoHasAccessVarying
        }
    }
    
    var accessListTitle: String {
        switch self {
        case .editor:
            return TextConstants.privateShareAccessEditor
        case .viewer:
            return TextConstants.privateShareAccessViewer
        case .varying:
            return TextConstants.privateShareAccessVarying
        case .owner:
            return ""
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
        case .varying:
            return 3
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
    var role: PrivateShareUserRole
    
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

enum PrivateSharePermission: String, Codable, Equatable {
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

struct CreateFolderResquestItem: Encodable {
    let uuid: String
    let folder: Bool = true
    let name: String
    let sizeInBytes: Int64 = 0
    let mimeType: String = "application/directory"
    
    var parameters: [String: Any] {
        dictionary
    }
}

struct UploadFileRequestItem: Encodable {
    let uuid: String
    let folder: Bool = false
    let name: String
    let sizeInBytes: Int64
    let mimeType: String
    
    var parameters: [String: Any] {
        dictionary
    }
}

struct PrivateSharedFolderItem: Equatable {
    let accountUuid: String
    let uuid: String
    let name: String
    let permissions: SharedItemPermission
    let type: PrivateShareType
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
    let expirationDate: Date?
    let conditions: [String]? //unknown array type
}
