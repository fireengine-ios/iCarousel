//
//  IAPProductsFetcher.swift
//  Depo
//
//  Created by Hady on 6/20/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import StoreKit

final class IAPProductsFetcher: NSObject, SKProductsRequestDelegate {

    typealias ReceiveProductsBlock = ([SKProduct]) -> Void

    private var completionBlockByRequest: [SKProductsRequest: ReceiveProductsBlock] = [:]

    func fetchProducts(withIdentifiers identifiers: Set<String>, completion: @escaping ReceiveProductsBlock) {
        let request = SKProductsRequest(productIdentifiers: identifiers)
        request.delegate = self
        completionBlockByRequest[request] = completion
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let completionBlock = completionBlockByRequest[request] else {
            return
        }

        completionBlockByRequest.removeValue(forKey: request)
        completionBlock(response.products)
    }
}
