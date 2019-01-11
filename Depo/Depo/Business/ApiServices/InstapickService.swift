//
//  InstapickService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/10/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON


protocol InstaPickServiceDelegate: class {
    func didRemoveAnalysis()
    func didFinishAnalysis()
}


protocol InstapickService: class {
    var delegates: MulticastDelegate<InstaPickServiceDelegate> {get}
    
    func getThumbnails(handler: @escaping (ResponseResult<[URL]>) -> Void)
    func getAnalysisCount(handler: @escaping (ResponseResult<AnalysisCount>) -> Void)
    
    //TODO: add real
    func removeAnalysis()
    func startAnalysis()
    //
}


final class InstapickServiceImpl: InstapickService {

    let sessionManager: SessionManager
    
    let delegates = MulticastDelegate<InstaPickServiceDelegate>()
    
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    
    func getThumbnails(handler: @escaping (ResponseResult<[URL]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.thumbnails)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let jsonArray = JSON(data: data).array else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.thumbnails) not array in response")
                        handler(.failed(error))
                        return
                    }
                    
                    let results = jsonArray
                        .flatMap { $0.string }
                        .flatMap { URL(string: $0) }
                    
                    handler(.success(results))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func removeAnalysis() {
        //TODO: add in the callback
        delegates.invoke { delegate in
            delegate.didRemoveAnalysis()
        }
    }
    
    func startAnalysis() {
        //TODO: add in the callback
        delegates.invoke { delegate in
            delegate.didFinishAnalysis()
        }
    }
    
    func getAnalysisCount(handler: @escaping (ResponseResult<AnalysisCount>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analysisCount)
            .customValidate()
            .responseData { response in
                
                /// server mock
                let results = AnalysisCount(left: 2, total: 32)
                handler(.success(results))
                
                /// !!! server logic. don't delete
//                switch response.result {
//                case .success(let data):
//                    let json = JSON(data: data)
//
//                    guard let results = AnalysisCount(json: json) else {
//                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analysisCount) not AnalysisCount in response")
//                        handler(.failed(error))
//                        return
//                    }
//
//                    handler(.success(results))
//                case .failure(let error):
//                    handler(.failed(error))
//                }
        }
    }
}

final class AnalysisCount {
    let left: Int
    let total: Int
    
    init(left: Int, total: Int) {
        self.left = left
        self.total = total
    }
    
    init?(json: JSON) {
        guard let left = json["left"].int, let total = json["total"].int else {
            assertionFailure()
            return nil
        }
        self.left = left
        self.total = total
    }
}
