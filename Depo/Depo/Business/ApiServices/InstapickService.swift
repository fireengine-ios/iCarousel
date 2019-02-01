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
    func startAnalyze(ids: [String], popupToDissmiss: UIViewController)
}


final class InstapickServiceImpl: InstapickService {
    
    private enum Keys {
        static let serverValue = "value"
    }

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
//                let results = [
//                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: nil, photoCount: nil, startedDate: nil),
//                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: nil, photoCount: nil, startedDate: nil)
//                ]
//                handler(.success(results))
                
                /// !!! server logic. don't delete
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    self?.delegates.invoke(invocation: { $0.didFinishAnalysis() })
                    
                    handler(.success(results))
                case .failure(let error):
                    print("error")
//                    assertionFailure(error.localizedDescription)
//                    handler(.failed(error))
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
                //handler(.success(()))
                
                /// !!! server logic. don't delete
                switch response.result {
                case .success(_):
                    self?.delegates.invoke(invocation: { $0.didRemoveAnalysis() })
                    handler(.success(()))
                case .failure(let error):
                    assertionFailure(error.localizedDescription)
                    handler(.failed(error))
                }
        }
    }
    
    func getAnalyzesCount(handler: @escaping (ResponseResult<InstapickAnalyzesCount>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzesCount)
            .customValidate()
            .responseData { response in
                
                /// server mock
                //let results = InstapickAnalyzesCount(left: 2, total: 32)
                //handler(.success(results))
                
                /// !!! server logic. don't delete
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = InstapickAnalyzesCount(json: json) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyzesCount) not AnalysisCount in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    assertionFailure(error.localizedDescription)
                    handler(.failed(error))
                }
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
//                if offset == 1 {
//                    handler(.success([]))
//                    return
//                }
//
//                let item1 = SearchItemResponse()
//                item1.createdDate = Date()
//                item1.id = 123
//                item1.uuid = UUID().uuidString
//                item1.metadata = BaseMetaData()
//                item1.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FFFF00")
//                item1.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FFFF00")
//                item1.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FFFF00")
//
//                let item2 = SearchItemResponse()
//                item2.createdDate = Date()
//                item2.id = 456
//                item2.uuid = UUID().uuidString
//                item2.metadata = BaseMetaData()
//                item2.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FF0000")
//                item2.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FF0000")
//                item2.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FF0000")
//
//                let results = [
//                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: item1, photoCount: 1, startedDate: Date.distantPast),
//                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: item2, photoCount: 1, startedDate: Date.distantPast)
//                ]
//                handler(.success(results))
                
                /// !!! server logic. don't delete
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    assertionFailure(error.localizedDescription)
                    handler(.failed(error))
                }
        }
    }
    
    func getAnalyzeDetails(id: String, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzeDetails,
                     method: .post,
                     encoding: id)
            .customValidate()
            .responseData { [weak self] response in
                
//                let item1 = SearchItemResponse()
//                item1.createdDate = Date()
//                item1.id = 123
//                item1.uuid = UUID().uuidString
//                item1.metadata = BaseMetaData()
//                item1.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FFFF00")
//                item1.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FFFF00")
//                item1.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FFFF00")
//
//                let item2 = SearchItemResponse()
//                item2.createdDate = Date()
//                item2.id = 456
//                item2.uuid = UUID().uuidString
//                item2.metadata = BaseMetaData()
//                item2.metadata?.smalURl = URL(string: "https://via.placeholder.com/100/FF0000")
//                item2.metadata?.mediumUrl = URL(string: "https://via.placeholder.com/300/FF0000")
//                item2.metadata?.largeUrl = URL(string: "https://via.placeholder.com/500/FF0000")
//
//                let results = [
//                    InstapickAnalyze(requestIdentifier: "123", rank: 5, hashTags: ["#hashTags1", "#hashTags2"], fileInfo: item1, photoCount: 1, startedDate: Date.distantPast),
//                    InstapickAnalyze(requestIdentifier: "567", rank: 4, hashTags: ["#hashTags3", "#hashTags4"], fileInfo: item2, photoCount: 1, startedDate: Date.distantPast)
//                ]
//                handler(.success(results))
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyzeHistory) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    assertionFailure(error.localizedDescription)
                    handler(.failed(error))
                }
        }
    }
    
    /// global logic
    func startAnalyze(ids: [String], popupToDissmiss: UIViewController) {
        startAnalyzes(ids: ids) { [weak self] result in
            switch result {
            case .success(let analysis):
                
                self?.getAnalyzesCount { result in
                    switch result {
                    case .success(let analyzesCount):
                        
                        popupToDissmiss.dismiss(animated: true, completion: {
                            
                            if let currentController = UIApplication.topController() {
                                let instapickDetailControlller = RouterVC().instaPickDetailViewController(models: analysis, analyzesCount: analyzesCount)
                                currentController.present(instapickDetailControlller, animated: true, completion: nil)
                            } else {
                                /// nothing to show
                                assertionFailure()
                            }
                        })
                        
                    case .failed(let error):
                        UIApplication.showErrorAlert(message: error.localizedDescription)
                    }
                }
                
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}

final class InstapickAnalyzesCount {
    let left: Int
    let total: Int
    let isFree: Bool
    let used: Int
    
    init(left: Int, total: Int, isFree: Bool) {
        self.left = left
        self.total = total
        self.isFree = isFree
        self.used = total - left
    }
    
    init?(json: JSON) {
        ///there is "used" key from server response. it is "total - remaining"
        guard
            let left = json["remaining"].int,
            let total = json["total"].int,
            let isFree = json["isFree"].bool
        else {
            assertionFailure()
            return nil
        }
        
        self.left = left
        self.total = total
        self.isFree = isFree
        self.used = total - left
    }
}

final class InstapickAnalyze {
    let requestIdentifier: String
    let rank: Float
    let score: Float
    let hashTags: [String]
    let fileInfo: SearchItemResponse?
    let photoCount: Int?
    let startedDate: Date?
    var isPicked: Bool = false
    // let message: String
    
    init(requestIdentifier: String, rank: Float, hashTags: [String], fileInfo: SearchItemResponse?, photoCount: Int?, startedDate: Date?, score: Float) {
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.score = score
        self.hashTags = hashTags
        self.fileInfo = fileInfo
        self.photoCount = photoCount
        self.startedDate = startedDate
    }

    init?(json: JSON) {
        guard
            let requestIdentifier = json["requestIdentifier"].string,
            let rank = json["rank"].float,
            let score = json["score"].float,
            let hashTags = json["hashTags"].array?.flatMap({ $0.string })
        else {
            assertionFailure()
            return nil
        }
        
        self.requestIdentifier = requestIdentifier
        self.rank = rank
        self.score = score
        self.hashTags = hashTags
        
        let fileInfo = json["fileInfo"]
        self.fileInfo = (fileInfo == JSON.null) ? nil : SearchItemResponse(withJSON: fileInfo)
        
        self.photoCount = json["photoCount"].int
        self.startedDate = json["startedDate"].date
    }
    
    func getSmallImageURL() -> URL? {
        return fileInfo?.metadata?.mediumUrl
    }
    
    func getLargeImageURL() -> URL? {
        return fileInfo?.metadata?.largeUrl
    }
}

extension InstapickAnalyze: Equatable {
    static func == (lhs: InstapickAnalyze, rhs: InstapickAnalyze) -> Bool {
        return lhs.requestIdentifier == rhs.requestIdentifier &&
            lhs.hashTags == rhs.hashTags &&
            lhs.rank == rhs.rank &&
            lhs.isPicked == rhs.isPicked &&
            lhs.fileInfo == rhs.fileInfo
    }
}


// MARK: - Examples


//        let instapickService: InstapickService = factory.resolve()

//        instapickService.getThumbnails { result in
//            switch result {
//            case .success(let urls):
//                print("---", urls)
//                if urls.isEmpty {
//                    print("--- urls.isEmpty")
//                }
//            case .failed(let error):
//                print("---", error.localizedDescription)
//            }
//        }

//        instapickService.removeAnalyzes(ids: ["fcace5da-a89f-4adb-b5c4-f57bf560f660"]) { result in
//            switch result {
//            case .success(_): //void
//                print("---", "removeAnalyzes success")
//            case .failed(let error):
//                print("---", error.localizedDescription)
//            }
//        }

//        instapickService.getAnalyzesCount { result in
//            switch result {
//            case .success(let analyzesCount):
//                print("---", analyzesCount.left)
//            case .failed(let error):
//                print("---", error.localizedDescription)
//            }
//        }

//        instapickService.startAnalyzes(ids: ["4b56d942-e2e9-441b-a9fd-44d7a37b102d"]) { result in
//            switch result {
//            case .success(let instapickAnalyze):
//                print("---", instapickAnalyze.first?.rank ?? "nil")
//            case .failed(let error):
//                print("---", error.localizedDescription)
//            }
//        }

//        instapickService.getAnalyzeHistory(offset: 0, limit: 100) { result in
//            switch result {
//            case .success(let instapickAnalyze):
//                print("---", instapickAnalyze.count)
//            case .failed(let error):
//                print("---", error.localizedDescription)
//            }
//        }

//        instapickService.getAnalyzeDetails(id: "f3dd5ac8-ba38-40d8-b46d-797bd88c6332") { result in
//            switch result {
//            case .success(let instapickAnalyze):
//                print("---", instapickAnalyze.count)
//            case .failed(let error):
//                print("---", error.localizedDescription)
//            }
//        }

