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
    let id: Int64?
    let hash: String?
    let name: String?
    let uuid: String?
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
    
    enum CodingKeys: String, CodingKey {
        case createdDateValue = "createdDate"
        case lastModifiedDateValue = "lastModifiedDate"
        
        case id, hash, name, uuid, bytes, folder, childCount, status, uploaderDeviceType, ugglaId, content_type, album, permissions, sharedBy
    }
}

//struct SharedFileInfoMetadata: Codable {
//
//}

struct SharedItemPermission: Codable {
    let granted: [String]?
    let bitmask: Int64?
}
