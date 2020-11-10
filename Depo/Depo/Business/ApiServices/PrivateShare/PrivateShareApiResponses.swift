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

struct PrivateShareObject {
    let items: [String]
    let message: String?
    var invitees: [PrivateShareContact]
    let type: PrivateShareType
    let duration: PrivateShareDuration
}

struct PrivateShareContact: Equatable {
    let displayName: String
    let username: String
    var role: PrivateShareUserRole
    
    static func == (lhs: PrivateShareContact, rhs: PrivateShareContact) -> Bool {
        return lhs.username == rhs.username
    }
}

enum PrivateShareUserRole: String, CaseIterable {
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

enum PrivateShareType: String {
    case file = "FILE"
    case folder = "FOLDER"
}

enum PrivateShareDuration: String, CaseIterable {
    case no = "NO_DURATION"
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
