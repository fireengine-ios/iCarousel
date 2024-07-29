//
//  HomeCardsService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

protocol HomeCardsService {
    var delegate: HomeCardsServiceImpDelegte? {get set}
    
    func all(handler: @escaping (ResponseResult<[HomeCardResponse]>) -> Void)
    func save(with id: Int, handler: @escaping ResponseVoid)
    func delete(with id: Int, handler: @escaping ResponseVoid)
    func updateItem(uuid: String, handler: @escaping (ResponseResult<WrapData>) -> Void)
    func getBestGroup(handler: @escaping (ResponseResult<BurstGroup>) -> Void)
    func getBestGroupWithId(with id: Int, handler: @escaping (ResponseResult<BurstGroupsWithId>) -> Void)
    func getCampaigns(handler: @escaping (ResponseResult<[Campaign]>) -> Void)
}

final class HomeCardsServiceImp {
    
    weak var delegate: HomeCardsServiceImpDelegte?
    let sessionManager: SessionManager
    private lazy var fileService = FileService.shared
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
}

protocol HomeCardsServiceImpDelegte: AnyObject {
    func needUpdateHomeScreen()
    func albumHiddenSuccessfully(_ successfully: Bool)
    func showSpinner()
    func hideSpinner()
}

extension HomeCardsServiceImp: HomeCardsService {
    
    func all(handler: @escaping (ResponseResult<[HomeCardResponse]>) -> Void) {
        sessionManager
            .request(RouteRequests.HomeCards.all)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let array = HomeCardResponse.array(from: data)
                    for (i, object) in array.enumerated() {
                        object.order = i + 1
                    }
                    handler(.success(array))
                case .failure(let error):
                    
                    debugLog("HomeCardsService all response: \(response)")
                    debugLog("HomeCardsService all statusCode: \(response.response?.statusCode ?? -1111)")
                    
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(.failed(backendError ?? error))
                }
            }
    }
    
    func save(with id: Int, handler: @escaping ResponseVoid) {
        let url = RouteRequests.HomeCards.card(with: id)
        sessionManager
            .request(url, method: .put)
            .customValidate()
            .responseVoid(handler)
    }
    
    func delete(with id: Int, handler: @escaping ResponseVoid) {
        let url = RouteRequests.HomeCards.card(with: id)
        sessionManager
            .request(url, method: .delete)
            .customValidate()
            .responseVoid(handler)
    }
    
    func updateItem(uuid: String, handler: @escaping (ResponseResult<WrapData>) -> Void) {
        fileService.updateDetail(uuids: uuid, success: { updatedItem in
            handler(.success(updatedItem))
        }) { error in
            handler(.failed(error))
        }
    }
    
    func getBestGroup(handler: @escaping (ResponseResult<BurstGroup>) -> Void) {
        SessionManager
         .customDefault
         .request(RouteRequests.HomeCards.bestScene)
         .customValidate()
         .responseObject(handler)
       }
    
    func getBestGroupWithId(with id: Int, handler: @escaping (ResponseResult<BurstGroupsWithId>) -> Void) {
        SessionManager
            .customDefault
            .request(RouteRequests.HomeCards.burstGroupFiles(for: id))
            .customValidate()
            .responseObject(handler)
    }
    
    func getCampaigns(handler: @escaping (ResponseResult<[Campaign]>) -> Void) {
        SessionManager
         .customDefault
         .request(RouteRequests.HomeCards.campaigns)
         .customValidate()
         .responseObject(handler)
    }
}
