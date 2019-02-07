import Alamofire
import SwiftyJSON

protocol InstaPickServiceDelegate: class {
    func didRemoveAnalysis()
    func didFinishAnalysis(_ analyses: [InstapickAnalyze])
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


final class InstapickServiceImpl {
    
    private enum Keys {
        static let serverValue = "value"
    }

    let sessionManager: SessionManager
    let delegates = MulticastDelegate<InstaPickServiceDelegate>()
    
    init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
}

extension InstapickServiceImpl: InstapickService {
    
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
                    let responseError = InstapickServiceImpl.handleBackendErrorIfCan(data: response.data) ?? error
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
                    let json = JSON(data: data)[Keys.serverValue]
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    self?.delegates.invoke(invocation: { $0.didFinishAnalysis(results) })
                    
                    handler(.success(results))
                case .failure(let error):
                    let responseError = InstapickServiceImpl.handleBackendErrorIfCan(data: response.data) ?? error
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
                    let responseError = InstapickServiceImpl.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
                }
        }
    }
    
    func getAnalyzesCount(handler: @escaping (ResponseResult<InstapickAnalyzesCount>) -> Void) {
        sessionManager
            .request(RouteRequests.Instapick.analyzesCount)
            .customValidate()
            .responseData { response in
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
                    let responseError = InstapickServiceImpl.handleBackendErrorIfCan(data: response.data) ?? error
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
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyze) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    let responseError = InstapickServiceImpl.handleBackendErrorIfCan(data: response.data) ?? error
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
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
                        let error = CustomErrors.serverError("\(RouteRequests.Instapick.analyzeHistory) not [InstapickAnalyze] in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                
                    handler(.success(results))
                case .failure(let error):
                    let responseError = InstapickServiceImpl.handleBackendErrorIfCan(data: response.data) ?? error
                    handler(.failed(responseError))
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

// MARK: - static
private extension InstapickServiceImpl {
    
    static func handleBackendErrorIfCan(data: Data?) -> Error? {
        guard let data = data, let status = JSON(data: data)["status"].string else {
            return nil
        }
        
        /// if there will be a lot of switch cases, can be created InstapickServerError with switch in it
        switch status {
        case "3104":
            return CustomErrors.text(TextConstants.instapickUnderConstruction)
        default:
            return nil
        }
    }
}
