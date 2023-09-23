//
//  PhotoPrintService.swift
//  Depo
//
//  Created by Ozan Salman on 15.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

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
    
    @discardableResult
    func photoPrintMyAddress(handler: @escaping (ResponseResult<[AddressResponse]>) -> Void) -> URLSessionTask? {
        debugLog("photoPrintMyAdress")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.myAddress)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func photoPrintAddAddress(addressName: String, recipientName: String, recipientNeighbourhood: String, recipientStreet: String, recipientBuildingNumber: String, recipientApartmentNumber: String, recipientCityId: Int, recipientDistrictId: Int, postalCode: Int, saveStatus: Bool, handler: @escaping ResponseHandler<AddressResponse>) -> URLSessionTask? {
        debugLog("photoPrintAddAdress")
        
        let parameters: [String: Any] = ["addressName": addressName,
                                   "recipientName" : recipientName,
                                   "recipientNeighbourhood" : recipientNeighbourhood,
                                   "recipientStreet" : recipientStreet,
                                   "recipientBuildingNumber" : recipientBuildingNumber,
                                   "recipientApartmentNumber" : recipientApartmentNumber,
                                   "recipientCity" : recipientCityId,
                                   "recipientDistrict" : recipientDistrictId,
                                   "postalCode" : postalCode,
                                   "saveStatus" : saveStatus]
        
        return SessionManager
            .customDefault
            .request(RouteRequests.addAddress,
                     method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func photoPrintUpdateAddress(id: Int, addressName: String, recipientName: String, recipientNeighbourhood: String, recipientStreet: String, recipientBuildingNumber: String, recipientApartmentNumber: String, recipientCityId: Int, recipientDistrictId: Int, postalCode: Int, saveStatus: Bool, handler: @escaping ResponseHandler<AddressResponse>) -> URLSessionTask? {
        debugLog("photoPrintUpdateAdress")
        
        let path = String(format: RouteRequests.updateAdress, id)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return nil
        }
        
        let parameters: [String: Any] = ["addressName": addressName,
                                   "recipientName" : recipientName,
                                   "recipientNeighbourhood" : recipientNeighbourhood,
                                   "recipientStreet" : recipientStreet,
                                   "recipientBuildingNumber" : recipientBuildingNumber,
                                   "recipientApartmentNumber" : recipientApartmentNumber,
                                   "recipientCity" : recipientCityId,
                                   "recipientDistrict" : recipientDistrictId,
                                   "postalCode" : postalCode,
                                   "saveStatus" : saveStatus]
        
        return SessionManager
            .customDefault
            .request(url,
                     method: .put,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func photoPrintCreateOrder(addressId: Int, fileUuidList: [String], handler: @escaping ResponseHandler<CreateOrderResponse>) -> URLSessionTask? {
        debugLog("photoPrintCreateOrder")
        
        let parameters: [String: Any] = ["addressId": addressId,
                                   "fileUuidList" : fileUuidList]
        
        return SessionManager
            .customDefault
            .request(RouteRequests.createOrder,
                     method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
}
