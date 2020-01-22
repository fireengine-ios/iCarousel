//
//  ActivityType.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation


//TODO: check if we should add hide/unhide, trash/restore activities
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
            return TextConstants.created
        case .added:
            return TextConstants.uploaded
        case .updated:
            return TextConstants.updated
        case .deleted:
            return TextConstants.deleted
        case .moved:
            return TextConstants.moved
        case .renamed:
            return TextConstants.renamed
        case .copied:
            return TextConstants.copied
        case .favourite:
            return TextConstants.markedAsFavourite
        }
    }
}
