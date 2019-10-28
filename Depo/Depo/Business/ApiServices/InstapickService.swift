import Alamofire
import SwiftyJSON

protocol InstaPickServiceDelegate: class {
    func didRemoveAnalysis()
    func didFinishAnalysis(_ analyses: [InstapickAnalyze])
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
    func startAnalyze(ids: [String], popupToDissmiss: UIViewController)
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
        guard let data = data, let status = JSON(data: data)["status"].string else {
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
                    let json = JSON(data: data)[Keys.serverValue]
                
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
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
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
                    let json = JSON(data: data)[Keys.serverValue]
                
                    guard let results = json.array?.flatMap({ InstapickAnalyze(json: $0) }) else {
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
    func startAnalyze(ids: [String], popupToDissmiss: UIViewController) {
        
        func showError(_ error: Error) {
            let popupVC = PopUpController.with(title: TextConstants.errorAlert, message: error.description, image: .error, buttonTitle: TextConstants.ok) { vc in
                vc.close {
                    popupToDissmiss.dismiss(animated: true, completion: nil)
                }
            }
            
            DispatchQueue.toMain {
                UIApplication.topController()?.present(popupVC, animated: false, completion: nil)
            }
        }
        
        let startAnalysisDate = Date()
        startAnalyzes(ids: ids) { [weak self] result in
            let eventLabel: GAEventLabel

            switch result {
            case .success(let analysis):
                eventLabel = .success
                
                self?.getAnalyzesCount { [weak self] result in
                    switch result {
                    case .success(let analyzesCount):
                        /// Popup time should be at least 5 seconds, even if the request returned success earlier
                        if Date().timeIntervalSince(startAnalysisDate) > NumericConstants.instapickTimeoutForAnalyzePhotos {
                            self?.dismissPopup(popupToDissmiss: popupToDissmiss, analyzesCount: analyzesCount, analysis: analysis)
                        } else {
                            /// If the request came before 5 seconds, then add the remaining time
                            let missingTimeout = NumericConstants.instapickTimeoutForAnalyzePhotos - Date().timeIntervalSince(startAnalysisDate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + missingTimeout) {
                                self?.dismissPopup(popupToDissmiss: popupToDissmiss, analyzesCount: analyzesCount, analysis: analysis)
                            }
                        }
                    case .failed(let error):
                        showError(error)
                    }
                }
                
            case .failed(let error):
                eventLabel = .failure
                showError(error)
            }
            self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .photopickAnalysis, eventLabel: eventLabel)
        }
    }
    
    // MARK: - Utility methods
    private func dismissPopup(popupToDissmiss: UIViewController, analyzesCount: InstapickAnalyzesCount, analysis: [InstapickAnalyze]) {
        popupToDissmiss.dismiss(animated: true, completion: {
                
            let instaPickCampaignService = InstaPickCampaignService()
            
            instaPickCampaignService.getController { [weak self] navController in
                if let navController = navController,
                    let controller = navController.topViewController as? InstaPickCampaignViewController,
                    let topVC = UIApplication.topController()
                {
                    controller.didClosed = {
                        self?.showResultWithoutCampaign(analyzesCount: analyzesCount, analysis: analysis)
                    }
                    topVC.present(navController, animated: true, completion: nil)
                } else {
                    self?.showResultWithoutCampaign(analyzesCount: analyzesCount, analysis: analysis)
                }
            }
        })
    }
    
    private func showResultWithoutCampaign(analyzesCount: InstapickAnalyzesCount, analysis: [InstapickAnalyze]) {
        if let currentController = UIApplication.topController() {
            let router = RouterVC()
            (router.getViewControllerForPresent() as? AnalyzeHistoryViewController)?.updateAnalyzeCount(with: analyzesCount)
            
            let instapickDetailControlller = router.instaPickDetailViewController(models: analysis,
                                                                                  analyzesCount: analyzesCount,                            isShowTabBar: self.isGridRelatedController(controller: router.getViewControllerForPresent()))
            
            currentController.present(instapickDetailControlller, animated: true, completion: nil)
        } else {
            /// nothing to show
            assertionFailure()
        }
    }
    
    private func isGridRelatedController(controller: UIViewController?) -> Bool {
        guard let controller = controller else {
            return false
        }
        return (controller is BaseFilesGreedViewController || controller is SegmentedController)
    }
    
}
