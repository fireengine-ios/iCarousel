//
//  QuickScrollItems.swift
//  Depo
//
//  Created by Aleksandr on 9/11/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum QuickScrollCategory {
    ///photos_and_videos|photos|videos
    case photosAndVideos
    case photos
    case videos
    
    var text: String {
        switch self {
        case .photosAndVideos:
            return "photos_and_videos"
        case .photos:
            return "photos"
        case .videos:
            return "videos"
        }
    }
    
    static func transfromFromString(text: String) -> QuickScrollCategory? {
        if text.contains(QuickScrollCategory.photosAndVideos.text) {
            return .photosAndVideos
        } else if text.contains(QuickScrollCategory.photos.text) {
            return .photos
        } else if text.contains(QuickScrollCategory.videos.text) {
            return .videos
        } else {
            return nil
        }
    }
}

struct GroupsListRequestItem {
    let group: String /// "group": "2014-6"
    let start: Int
    let end: Int
}

final class QuickScrollGroupItem {
    let group: String /// "group": "2014-6"
    let count: Int
    
    private let groupJsonKey = "group"
    private let countJsonKey = "count"
    
    init(group: String, count: Int) {
        self.group = group
        self.count = count
    }
    
    init(json: JSON) {
        group = json[groupJsonKey].stringValue
        count = json[countJsonKey].intValue
    }
}

final class QuickScrollGroupsListItem {
    let group: String
    let start: Int ///Start point for the group.
    let end: Int
    var files = [BaseDataSourceItem]()///check the type
    ///EXAMPLE:
    ///    group": "2014-6",
    ///    "start": 10,
    ///    "end": 15,
    ///    "files"
    private let groupJsonKey = "group"
    private let startJsonKey = "start"
    private let endJsonKey = "end"
    private let filesJsonKey = "files"
    
    init(json: JSON) {
        group = json[groupJsonKey].stringValue
        start = json[startJsonKey].intValue
        end = json[endJsonKey].intValue
        var array = json[filesJsonKey].arrayValue
    }
    
}

final class QuickScrollRangeListItem {
    ///*----
    ///NOW:
    //        ▿ {
    //            "total" : 128
    //            "files" : []
    //            "group": "photos_and_videos
    ///USED TO BE:
    //    "group": "photos_and_videos:3",
    //    "start": 0,
    //    "end": 1526971205110,
    //    "total": 4,
    //    "files": [
    //    List of FileInfo for the files found in range]
    ///----*
//    let startDate: Date?
//    let endDate: Date?
    let size: Int
    let category: QuickScrollCategory?
    var files = [WrapData]()///check the type

    private let startDateJsonKey = "startDate"
    private let endDateJsonKey = "endDate"
    private let sizeJsonKey = "total"
    private let categotyJsonKey = "group"
    private let filesJsonKey = "files"
    
    init(json: JSON) {
//        startDate = json[startDateJsonKey].date ///Seems like Volcan removed these
//        endDate = json[endDateJsonKey].date
        size = json[sizeJsonKey].intValue
        category = QuickScrollCategory.transfromFromString(text: json[categotyJsonKey].stringValue)
        let itemsJson: [JSON] = json[filesJsonKey].array ?? []
        files = itemsJson.map { WrapData(searchResponse: $0) }
        debugPrint("all created")
    }

}
