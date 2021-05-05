//
//  PrintService.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrintService: NSObject {
    static let path = "https://www.sosyopix.com/life-box"

    static func dataJSON(with data: [Item], requestId: String) -> Data? {
        var photos: [PrintServiceData.Print.Photo] = []
        for item in data {
            let url = item.urlToFile?.absoluteString ?? ""
            photos.append(PrintServiceData.Print.Photo(original: url, thumb: url))
        }

        let print = PrintServiceData.Print(dateCreated: Date(), dateSend: Date(),
                                           photos: photos, requestId: requestId,
                                           totalPhotos: data.count,
                                           uid: RouteRequests.baseUrl.absoluteString)

        let jsonEncoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        jsonEncoder.dateEncodingStrategy = .formatted(formatter)

        do {
            let jsonData = try jsonEncoder.encode(print)
            return jsonData
        } catch {
            return nil
        }
    }

}

private struct PrintServiceData: Codable {
    let data: Print
    
    struct Print: Codable {
        let dateCreated: Date
        let dateSend: Date
        let photos: [Photo]
        let requestId: String
        let totalPhotos: Int
        let uid: String
        
        enum CodingKeys: String, CodingKey {
            case dateCreated =  "date_created", dateSend =  "date_send", requestId = "request_id", totalPhotos =  "total_photos", uid, photos
        }
        
        struct Photo: Codable {
            let original: String
            let thumb: String
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(dateCreated, forKey: .dateCreated)
            try container.encode(dateSend, forKey: .dateSend)
            try container.encode(photos, forKey: .photos)
            try container.encode(requestId, forKey: .requestId)
            try container.encode(totalPhotos, forKey: .totalPhotos)
            try container.encode(uid, forKey: .uid)
        }
    }
}
