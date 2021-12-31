//
//  RemoteTextRecognitionService.swift
//  Depo
//
//  Created by Hady on 12/27/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

protocol RemoteTextRecognitionServiceProtocol {
    @discardableResult
    func process(fileUUID: String, completion: @escaping (RemoteTextRecognitionModel?) -> Void) -> URLSessionTask?
}

final class RemoteTextRecognitionService: RemoteTextRecognitionServiceProtocol {
    private let sessionManager: SessionManager

    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }

    @discardableResult
    func process(fileUUID: String, completion: @escaping (RemoteTextRecognitionModel?) -> Void) -> URLSessionTask? {
//        let url = Bundle.main.url(forResource: "ocr", withExtension: "json")!
//        let data = try! Data(contentsOf: url)
//        completion(try! JSONDecoder().decode(RemoteTextRecognitionModel.self, from: data))
//        return nil
        let parameters = [fileUUID].asParameters()
        return sessionManager
            .request(RouteRequests.ocrProcess, method: .post,
                     parameters: parameters, encoding: ArrayEncoding())
            .customValidate()
            .responseObject { (result: ResponseResult<RemoteTextRecognitionResponse>) in
                do {
                    let response = try result.asSwiftResult().get().value
                    completion(response.first)
                } catch {
                    completion(nil)
                }
            }
            .task
    }

}
