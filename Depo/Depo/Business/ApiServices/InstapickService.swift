import Alamofire
import SwiftyJSON

protocol InstaPickServiceDelegate: class {
    func didRemoveAnalysis()
    func didFinishAnalysis(_ analyses: [InstapickAnalyze])
}

struct AnalyzeResult {
    let analyzesCount: InstapickAnalyzesCount
    let analysis: [InstapickAnalyze]
}

/// https://wiki.life.com.by/x/IjAWBQ
protocol InstapickService: class {
    var delegates: MulticastDelegate<InstaPickServiceDelegate> { get }
    
    func getThumbnails(handler: @escaping (ResponseResult<[URL]>) -> Void)
    func getAnalyzesCount(handler: @escaping (ResponseResult<InstapickAnalyzesCount>) -> Void)
    func startAnalyzes(ids: [String], handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
    func removeAnalyzes(ids: [String], handler: @escaping (ResponseResult<Void>) -> Void)
    func getAnalyzeHistory(offset: Int, limit: Int, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
    func getAnalyzeDetails(id: String, handler: @escaping (ResponseResult<[InstapickAnalyze]>) -> Void)
    func startAnalyze(ids: [String], completion: @escaping (ResponseResult<AnalyzeResult>) -> Void)
}

final class InstapickServiceImpl {
    
    private enum Keys {
        static let serverValue = "value"
    }
    
    private let sessionManager: SessionManager
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    let delegates = MulticastDelegate<InstaPickServiceDelegate>()
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    private func handleBackendErrorIfCan(data: Data?) -> Error? {
        guard let data = data, let status = JSON(data)["status"].string else {
            return nil
        }
        
        let text: String
        
        switch status {
        case "3104":
            text = TextConstants.instapickUnderConstruction
        case "3102":
            text = TextConstants.instapickUnsupportedFileType
        case "3105":
            text = TextConstants.instapickNoAvailableUnitsLeft
        case "3106":
            text = TextConstants.instapickConnectionProblemOccured
        default:
            return nil
        }
        
        return CustomErrors.text(text)
    }
}

extension InstapickServiceImpl: InstapickService {
    
    func getThumbnails(handler: @escaping (ResponseResult<[URL]>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.thumbnails)
            .customValidate()
            .responseData { [weak self] response in
                switch response.result {
                case .success(let data):
                    guard let jsonArray = JSON(data).array else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.thumbnails) not array in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                    
                    let results = jsonArray
                        .compactMap { $0.string }
                        .compactMap { URL(string: $0) }
                    
                    handler(.success(results))
                case .failure(let error):
                    let responseError = self?.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
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
                switch response.result {
                case .success(let data):
                    let json = JSON(data)[Keys.serverValue]
                    guard let results = json.array?.compactMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    self?.delegates.invoke(invocation: { $0.didFinishAnalysis(results) })
                    
                    handler(.success(results))
                case .failure(let error):
                    let responseError = self?.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
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
                switch response.result {
                case .success(_):
                    self?.delegates.invoke(invocation: { $0.didRemoveAnalysis() })
                    handler(.success(()))
                case .failure(let error):
                    let responseError = self?.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
                }
        }
    }
    
    func getAnalyzesCount(handler: @escaping (ResponseResult<InstapickAnalyzesCount>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzesCount)
            .customValidate()
            .responseData { [weak self] response in
                switch response.result {
                case .success(let data):
                    let json = JSON(data)[Keys.serverValue]
                
                    guard let results = InstapickAnalyzesCount(json: json) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyzesCount) not AnalysisCount in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    let responseError = self?.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
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
                
                switch response.result {
                case .success(let data):
                    let json = JSON(data)[Keys.serverValue]
                
                    guard let results = json.array?.compactMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    let responseError = self?.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
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
                switch response.result {
                case .success(let data):
                    let json = JSON(data)[Keys.serverValue]
                
                    guard let results = json.array?.compactMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyzeHistory) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    let responseError = self?.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
                }
        }
    }

    /// global logic
    func startAnalyze(ids: [String], completion: @escaping (ResponseResult<AnalyzeResult>) -> ()) {
        
        let startAnalysisDate = Date()
        startAnalyzes(ids: ids) { [weak self] result in
            let eventLabel: GAEventLabel

            switch result {
            case .success(let analysis):
                eventLabel = .success
                
                self?.getAnalyzesCount { [weak self] result in
                    switch result {
                    case .success(let analyzesCount):
                        self?.analyticsService.trackPhotopickAnalysis(eventLabel: eventLabel, dailyDrawleft: analyzesCount.left, totalDraw: analyzesCount.total)
                        
                        /// Popup time should be at least 5 seconds, even if the request returned success earlier
                        if Date().timeIntervalSince(startAnalysisDate) > NumericConstants.instapickTimeoutForAnalyzePhotos {
                            let result = AnalyzeResult(analyzesCount: analyzesCount, analysis: analysis)
                            completion(.success(result))

                        } else {
                            /// If the request came before 5 seconds, then add the remaining time
                            let missingTimeout = NumericConstants.instapickTimeoutForAnalyzePhotos - Date().timeIntervalSince(startAnalysisDate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + missingTimeout) {
                                let result = AnalyzeResult(analyzesCount: analyzesCount, analysis: analysis)
                                completion(.success(result))
                            }
                        }
                    case .failed(let error):
                        completion(.failed(error))
                    }
                }
                
            case .failed(let error):
                eventLabel = .failure
                self?.analyticsService.trackPhotopickAnalysis(eventLabel: eventLabel, dailyDrawleft: nil, totalDraw: nil)
                completion(.failed(error))
            }
        }
    }
}
