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
        for index in 1...5 {
            contacts.append(SuggestedApiContact(type: "USER",
                                                identifier: "user_\(index)",
                                                username: "\(index)5555555",
                                                email: "email_\(index)@gmail.com",
                                                name: "user_\(index)",
                                                picture: nil))
        }
        return contacts
    }
}
