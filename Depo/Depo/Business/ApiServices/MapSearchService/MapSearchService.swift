//
//  MapSearchService.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class MapSearchService: BaseRequestService {
    @discardableResult
    func getMediaGroups(at zoomLevel: Int, northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D,
                        handler: @escaping ResponseArrayHandler<MapMediaGroup>) -> URLSessionTask? {

        let path = String(format: RouteRequests.map, northWest.latitude, northWest.longitude,
                          southEast.latitude, southEast.longitude, zoomLevel)

        let url = RouteRequests.baseUrl +/ path
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
}
