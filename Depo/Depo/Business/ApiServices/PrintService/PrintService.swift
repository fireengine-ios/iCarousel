//
//  PrintService.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 17.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Alamofire

final class PrintService {
    static let path = "https://www.sosyopix.com/life-box"

    static var isEnabled: Bool {
        #if LIFEBOX
        let remoteConfig = FirebaseRemoteConfig.shared
        let deviceLocale = Device.locale.lowercased()
        return remoteConfig.printOptionEnabled && remoteConfig.printOptionEnabledLanguages.contains(deviceLocale)
        #else
        return false
        #endif
    }

    static func dataJSON(with data: [Item], userId: String) -> Data? {
        var photos: [PrintServiceData.Print.Photo] = []
        for item in data {
            let url = item.urlToFile?.absoluteString ?? ""
            photos.append(PrintServiceData.Print.Photo(original: url, thumb: url))
        }

        let print = PrintServiceData.Print(dateCreated: Date(), dateSend: Date(),
                                           photos: photos, requestId: UUID().uuidString,
                                           totalPhotos: data.count,
                                           uid: userId)

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

    @discardableResult
    func sendLog(for items: [Item], handler: @escaping ResponseVoid) -> URLSessionTask? {
        let uuids = items.map { $0.uuid }.asParameters()

        return SessionManager
            .customDefault
            .request(
                RouteRequests.Print.log,
                method: .post,
                parameters: uuids,
                encoding: ArrayEncoding()
            )
            .customValidate()
            .responseVoid(handler)
            .task
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
