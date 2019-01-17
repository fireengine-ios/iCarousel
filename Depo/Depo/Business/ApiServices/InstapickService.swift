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

/// https://wiki.life.com.by/x/IjAWBQ
protocol InstapickService: class {
    var delegates: MulticastDelegate<InstaPickServiceDelegate> {get}
    
    func getThumbnails(handler: @escaping (ResponseResult<[URL]>) -> Void)
    func getAnalyzesCount(handler: @escaping (ResponseResult<InstapickAnalyzesCount>) -> Void)
    func startAnalyzes(ids: [String], handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
    func removeAnalyzes(ids: [String], handler: @escaping (ResponseResult<Void>) -> Void)
    func getAnalyzeHistory(offset: Int, limit: Int, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
    func getAnalyzeDetails(id: String, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
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
    
    func startAnalyzes(ids: [String], handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyze,
                     method: .post,
                     parameters: ids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseData { [weak self] response in
                
                /// server mock
                let results = [
                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: nil, photoCount: nil, startedDate: nil),
                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: nil, photoCount: nil, startedDate: nil)
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
    
    func removeAnalyzes(ids: [String], handler: @escaping (ResponseResult<Void>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.removeAnalyzes,
                     method: .delete,
                     parameters: ids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseData { [weak self] response in
                
                /// server mock
                handler(.success(()))
                
                /// !!! server logic. don't delete
                //switch response.result {
                //case .success(_):
                //    handler(.success(()))
                //case .failure(let error):
                //    assertionFailure(error.localizedDescription)
                //    handler(.failed(error))
                //}
        }
    }
    
    func getAnalyzesCount(handler: @escaping (ResponseResult<InstapickAnalyzesCount>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzesCount)
            .customValidate()
            .responseData { response in
                
                /// server mock
                let results = InstapickAnalyzesCount(left: 2, total: 32)
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
    
    func getAnalyzeHistory(offset: Int, limit: Int, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzeHistory,
                     parameters: ["pageSize": limit,
                                  "pageNumber": offset],
                     encoding: URLEncoding.default)
            .customValidate()
            .responseData { [weak self] response in
                
                /// server mock
                if offset == 1 {
                    handler(.success([]))
                    return
                }
                
                let item1 = SearchItemResponse()
                item1.createdDate = Date()
                item1.id = 123
                item1.uuid = UUID().uuidString
                item1.metadata = BaseMetaData()
                item1.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FFFF00")
                item1.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FFFF00")
                item1.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FFFF00")
                
                let item2 = SearchItemResponse()
                item2.createdDate = Date()
                item2.id = 456
                item2.uuid = UUID().uuidString
                item2.metadata = BaseMetaData()
                item2.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FF0000")
                item2.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FF0000")
                item2.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FF0000")
                
                let results = [
                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: item1, photoCount: 1, startedDate: Date.distantPast),
                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: item2, photoCount: 1, startedDate: Date.distantPast)
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
    
    func getAnalyzeDetails(id: String, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzeDetails,
                     encoding: id)
            .customValidate()
            .responseData { [weak self] response in
                
                let item1 = SearchItemResponse()
                item1.createdDate = Date()
                item1.id = 123
                item1.uuid = UUID().uuidString
                item1.metadata = BaseMetaData()
                item1.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FFFF00")
                item1.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FFFF00")
                item1.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FFFF00")
                
                let item2 = SearchItemResponse()
                item2.createdDate = Date()
                item2.id = 456
                item2.uuid = UUID().uuidString
                item2.metadata = BaseMetaData()
                item2.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FF0000")
                item2.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FF0000")
                item2.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FF0000")
                
                let results = [
                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: item1, photoCount: 1, startedDate: Date.distantPast),
                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: item2, photoCount: 1, startedDate: Date.distantPast)
                ]
                handler(.success(results))
                
                //switch response.result {
                //case .success(let data):
                //    let json = JSON(data: data)
                //
                //    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                //        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyzeHistory) not [InstapickAnalyze] in response")
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

final class InstapickAnalyzesCount {
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
    let rank: Float
    let hashTags: [String]
    let fileInfo: SearchItemResponse?
    let photoCount: Int?
    let startedDate: Date?
    var isPicked: Bool = false
    // let message: String
    
    init(requestIdentifier: String, rank: Float, hashTags: [String], fileInfo: SearchItemResponse?, photoCount: Int?, startedDate: Date?) {
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.hashTags = hashTags
        self.fileInfo = fileInfo
        self.photoCount = photoCount
        self.startedDate = startedDate
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
        
        self.photoCount = json["photoCount"].int
        self.startedDate = json["startedDate"].date
    }
    
    func getSmallImageURL() -> URL? {
        return fileInfo?.metadata?.smalURl
    }
    
    func getLargeImageURL() -> URL? {
        return fileInfo?.metadata?.largeUrl
    }
}


// MARK: - Examples

//let instapickService: InstapickService = factory.resolve()
//
//instapickService.getThumbnails { result in
//    switch result {
//    case .success(let urls):
//        print("---", urls)
//        if urls.isEmpty {
//            print("--- urls.isEmpty")
//        }
//    case .failed(let error):
//        print("---", error.localizedDescription)
//    }
//}
//
//instapickService.getAnalysisCount { result in
//    switch result {
//    case .success(let analysisCount):
//        print("---", analysisCount.left)
//    case .failed(let error):
//        print("---", error.localizedDescription)
//    }
//}
//
//instapickService.startAnalysis(ids: ["111", "222"]) { result in
//    switch result {
//    case .success(let instapickAnalyze):
//        print("---", instapickAnalyze.first?.rank ?? "nil")
//    case .failed(let error):
//        print("---", error.localizedDescription)
//    }
//}
