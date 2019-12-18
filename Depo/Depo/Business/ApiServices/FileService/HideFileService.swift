//
//  HideFileService.swift
//  Depo
//
//  Created by Konstantin Studilin on 13/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


final class HideFileService {
    
    private lazy var sessionManager: SessionManager = factory.resolve()
    
    @discardableResult
    func hideItems(_ items: [WrapData], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideItems")
        let ids = items.compactMap { $0.uuid }
        return hideItemsByUuids(ids, handler: handler)
    }
    
    private func hideItemsByUuids(_ uuids: [String],
                                  handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideItemsByUuids")
        
        return sessionManager
            .request(RouteRequests.FileSystem.hide,
                     method: .delete,
                     parameters: uuids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
}
