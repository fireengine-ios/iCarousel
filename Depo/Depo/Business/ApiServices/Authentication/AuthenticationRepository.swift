//
//  AuthenticationRepository.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 12/10/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import Alamofire
//import PromiseKit

protocol AuthenticationRepository {
//    func signIn(username: String, password: String) -> Promise<Void>
}

final class AuthenticationRepositoryImp {
    let sessionManager: SessionManager
    let tokenStorage: TokenStorage
    
    init(sessionManager: SessionManager, tokenStorage: TokenStorage) {
        self.sessionManager = sessionManager
        self.tokenStorage = tokenStorage
    }
}

extension AuthenticationRepositoryImp: AuthenticationRepository {
    
    func signIn(username: String, password: String) {
//        let params: [String : Any] =  [
//            "username": username,
//            "password": password,
//            "deviceInfo": [
//                "name": "MacBook Pro — user",
//                "deviceType": "IPHONE",
//                "uuid":  "621DF1D4-D76E-451C-9609-8B54E7A4F8C1"
//            ]
//        ]
//
//        return Promise { (fulfill, reject) in
//            sessionManager.request(URLs.login, method: .post, parameters: params, encoding: JSONEncoding.prettyPrinted)
//                .validate()
//                .responseString { response in
//
//                    debugPrint(response)
//                    switch response.result {
//                    case .success(_):
//                        if let headers = response.response?.allHeaderFields as? [String: Any],
//                            let accessToken = headers["X-Auth-Token"] as? String,
//                            let refreshToken = headers["X-Remember-Me-Token"] as? String
//                        {
//                            self.tokenStorage.accessToken = accessToken
//                            self.tokenStorage.refreshToken = refreshToken
//                            fulfill(())
//                        } else {
//                            let error = ServerError(code: response.response?.statusCode ?? -1, data: response.data)
//                            reject(error)
//                        }
//                    case .failure(let error):
//                        reject(error)
//                    }
//            }
//        }
    }
    
//    func logut() {
//        tokenStorage.accessToken = nil
//        tokenStorage.refreshToken = nil
//    }
    
    //return sessionManager
    //    .request(URLs.login, method: .post, parameters: credentials.toJSON(), encoding: JSONEncoding.default)
    //    .validate()
    //    .responseObject(orError: BackendError.self)

}
