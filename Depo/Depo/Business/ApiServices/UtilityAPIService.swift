//
//  UtilityAPIService.swift
//  Depo
//
//  Created by Hady on 9/9/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Alamofire

/// A common place for utility endpoints
final class UtilityAPIService {

    func resolveDeepLink(actionString: String,
                         completion: @escaping (_ resolvedDeepLinkURL: URL?) -> Void) {
        let params: Parameters = ["link": actionString]

        SessionManager
            .customDefault
            .request(RouteRequests.resolveDeepLink, method: .post,
                     parameters: params, encoding: JSONEncoding.default)
            .customValidate()
            .responseObject { (response: ResponseResult<ResolveDeepLinkResponse>) in
                guard let response = try? response.asSwiftResult().get(),
                      let target = response.target,
                      let url = URL(string: target) else {
                    completion(nil)
                    return
                }

                completion(url)
            }
    }
}

extension UtilityAPIService {
    private struct ResolveDeepLinkResponse: Codable {
        let target: String?
    }
}
