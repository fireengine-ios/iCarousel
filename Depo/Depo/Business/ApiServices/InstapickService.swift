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
    
    //TODO: INSTAPICK add real
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
        //TODO: INSTAPICK add in the callback
        delegates.invoke { delegate in
            delegate.didRemoveAnalysis()
        }
    }
    
    func startAnalysis() {
        //TODO: INSTAPICK add in the callback
        delegates.invoke { delegate in
            delegate.didFinishAnalysis()
        }
    }
}
