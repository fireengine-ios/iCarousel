//
//  ActivityType.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

enum ActivityType: String {
    case welcome = "WELCOME"
    case added = "ADDED"
    case updated = "UPDATED"
    case deleted = "DELETED"
    case moved = "MOVED"
    case renamed = "RENAMED"
    case copied = "COPIED"
    case favourite = "FAVOURITE"
}
extension ActivityType {
    var displayString: String {
        switch self {
        case .welcome:
            return "created"
        case .added:
            return "uploaded"
        case .updated:
            return "updated"
        case .deleted:
            return "deleted"
        case .moved:
            return "moved"
        case .renamed:
            return "renamed"
        case .copied:
            return "copied"
        case .favourite:
            return "marked as favourite"
        }
    }
}
