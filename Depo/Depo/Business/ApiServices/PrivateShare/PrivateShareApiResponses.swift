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
    let type: String?
    let identifier: String?
    let username: String?
    let email: String?
    var name: String?
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
    let metadata: SharedFileInfoMetaData
    let album: [FileAlbum]?
    //        "location": {},
    let permissions: SharedItemPermission?
    let sharedBy: [SuggestedApiContact]?
    var members: [SharedContact]?
    
    
    var fileType: FileType {
        return FileType(type: content_type, fileName: name)
    }
}

struct SharedFileInfoMetaData: Codable {
    let isFavourite: Bool?
    
    let thumbnailLarge: URL?
    let thumbnailMedium: URL?
    let thumbnailSmall: URL?
    
    let originalHash: String?
    let originalBytes: Int64?
    
    let imageHeight: Int?
    let imageWidth: Int?
    let imageOrientation: Int? //enum?
    let imageDateTime: Date?
    
    let latitude: Double?
    let longitude: Double?
    
    private enum CodingKeys: String, CodingKey {
        case isFavourite = "X-Object-Meta-Favourite"
        case thumbnailLarge = "Thumbnail-Large"
        case thumbnailMedium = "Thumbnail-Medium"
        case thumbnailSmall = "Thumbnail-Small"
        
        case originalHash = "X-Object-Meta-Ios-Metadata-Hash"
        case originalBytes = "Original-Bytes"
        
        case imageHeight = "Image-Height"
        case imageWidth = "Image-Width"
        case imageOrientation = "Image-Orientation"
        case imageDateTime = "Image-DateTime"
        
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        originalBytes = JSON(try container.decodeIfPresent(String.self, forKey: .originalBytes) ?? "").int64
        isFavourite = JSON(try container.decodeIfPresent(String.self, forKey: .isFavourite) ?? "").boolFromString
        
        thumbnailLarge = JSON(try container.decodeIfPresent(String.self, forKey: .thumbnailLarge) ?? "").url
        thumbnailMedium = JSON(try container.decodeIfPresent(String.self, forKey: .thumbnailMedium) ?? "").url
        thumbnailSmall = JSON(try container.decodeIfPresent(String.self, forKey: .thumbnailSmall) ?? "").url
        
        originalHash = try container.decodeIfPresent(String.self, forKey: .originalHash)
        
        imageHeight = JSON(try container.decodeIfPresent(String.self, forKey: .imageHeight) ?? "").int
        imageWidth = JSON(try container.decodeIfPresent(String.self, forKey: .imageWidth) ?? "").int
        imageOrientation = JSON(try container.decodeIfPresent(String.self, forKey: .imageOrientation) ?? "").int
        
        imageDateTime = JSON(try container.decodeIfPresent(String.self, forKey: .imageDateTime) ?? "").date
        
        latitude = JSON(try container.decodeIfPresent(String.self, forKey: .latitude) ?? "").double
        longitude = JSON(try container.decodeIfPresent(String.self, forKey: .longitude) ?? "").double
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

enum PrivateShareItemType: String, Encodable {
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

struct SharedContact: Codable {
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
