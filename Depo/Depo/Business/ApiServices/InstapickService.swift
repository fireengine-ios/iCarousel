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
    func getAnalysisCount(handler: @escaping (ResponseResult<InstapickAnalysisCount>) -> Void)
    func startAnalysis(ids: [String], handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
    
    //TODO: add real
    func removeAnalysis()
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
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                    
                    let results = jsonArray
                        .flatMap { $0.string }
                        .flatMap { URL(string: $0) }
                    
                    handler(.success(results))
                case .failure(let error):
                    assertionFailure(error.localizedDescription)
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
    
    func startAnalysis(ids: [String], handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyze,
                     method: .post,
                     parameters: ids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseData { [weak self] response in
                
                /// server mock
                let results = [
                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: nil),
                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: nil)
                ]
                handler(.success(results))
                
                /// !!! server logic. don't delete
                //switch response.result {
                //case .success(let data):
                //    let json = JSON(data: data)
                //
                //    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                //        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                //        assertionFailure(error.localizedDescription)
                //        handler(.failed(error))
                //        return
                //    }
                //
                //    handler(.success(results))
                //case .failure(let error):
                //    assertionFailure(error.localizedDescription)
                //    handler(.failed(error))
                //}
                
                
                //TODO: add in the callback
                self?.delegates.invoke { delegate in
                    delegate.didFinishAnalysis()
                }
        }
    }
    
    func getAnalysisCount(handler: @escaping (ResponseResult<InstapickAnalysisCount>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analysisCount)
            .customValidate()
            .responseData { response in
                
                /// server mock
                let results = InstapickAnalysisCount(left: 2, total: 32)
                handler(.success(results))
                
                /// !!! server logic. don't delete
                //switch response.result {
                //case .success(let data):
                //    let json = JSON(data: data)
                //
                //    guard let results = InstapickAnalysisCount(json: json) else {
                //        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analysisCount) not AnalysisCount in response")
                //        assertionFailure(error.localizedDescription)
                //        handler(.failed(error))
                //        return
                //    }
                //
                //    handler(.success(results))
                //case .failure(let error):
                //    assertionFailure(error.localizedDescription)
                //    handler(.failed(error))
                //}
        }
    }
}

final class InstapickAnalysisCount {
    let left: Int
    let total: Int
    
    init(left: Int, total: Int) {
        self.left = left
        self.total = total
    }
    
    init?(json: JSON) {
        guard
            let left = json["left"].int,
            let total = json["total"].int
        else {
            assertionFailure()
            return nil
        }
        self.left = left
        self.total = total
    }
}

final class InstapickAnalyze {
    let requestIdentifier: String
    // let message: String
    let rank: Float
    let hashTags: [String]
    let fileInfo: SearchItemResponse?
    
    init(requestIdentifier: String, rank: Float, hashTags: [String], fileInfo: SearchItemResponse?) {
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.hashTags = hashTags
        self.fileInfo = fileInfo
    }

    init?(json: JSON) {
        guard
            let requestIdentifier = json["requestIdentifier"].string,
            let rank = json["rank"].float,
            let hashTags = json["hashTags"].array?.flatMap({ $0.string })
        else {
            assertionFailure()
            return nil
        }
        
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.hashTags = hashTags
        
        let fileInfo = json["fileInfo"]
        self.fileInfo = fileInfo.exists() ? SearchItemResponse(withJSON: fileInfo) : nil
    }
}
