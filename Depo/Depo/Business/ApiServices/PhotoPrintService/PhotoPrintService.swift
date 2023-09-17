//
//  PhotoPrintService.swift
//  Depo
//
//  Created by Ozan Salman on 15.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class PhotoPrintService: BaseRequestService {
    
    @discardableResult
    func photoPrintCity(handler: @escaping (ResponseResult<[CityResponse]>) -> Void) -> URLSessionTask? {
        debugLog("photoPrintCity")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.city)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func photoPrintDistrict(id: Int, handler: @escaping (ResponseResult<[DistrictResponse]>) -> Void) -> URLSessionTask? {
        debugLog("photoPrintDistrict")
        
        let path = String(format: RouteRequests.district, id)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return nil
        }
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
}
