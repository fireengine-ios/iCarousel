//
//  IAPManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import StoreKit

final class IAPManager: NSObject {
    
    static let shared = IAPManager()
    
    typealias OfferAppleHandler = ([OfferApple]) -> Void
    typealias PurchaseHandler = (_ isSuccess: PurchaseResult) -> Void
    
    override private init() {
        super.init()
        setupSKPaymentQueue()
    }
    
    var offerAppleHandler: OfferAppleHandler = {_ in }
    var purchaseHandler: PurchaseHandler = {_ in }
    
    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    private func setupSKPaymentQueue() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().transactions.forEach { transaction in
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func loadProducts(productIds: [String], handler: @escaping OfferAppleHandler) {
        offerAppleHandler = handler
        let request = SKProductsRequest(productIdentifiers: Set(productIds))
        request.delegate = self
        request.start()
    }
    
    func purchase(offerApple: OfferApple, handler: @escaping PurchaseHandler) {
        if !canMakePayments { return }
        purchaseHandler = handler
        let payment = SKPayment(product: offerApple.skProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    var receipt: String? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl)
            else { return nil }
        return receiptData.base64EncodedString(options: .lineLength64Characters)
    }
}

extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let sortedOffers = response.products
            .map { OfferApple(skProduct: $0) }
            .sorted { $0.rawPrice < $1.rawPrice }
        offerAppleHandler(sortedOffers)
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            //let productId = transaction.payment.productIdentifier
            switch transaction.transactionState {
            case .purchased:
                if let productId = transaction.transactionIdentifier,
                    let type = MenloworksSubscriptionProductID(rawValue: productId) {
                    MenloworksAppEvents.onSubscriptionPurchaseCompleted(type)
                }
                purchaseHandler(.success)
            case .failed:
                guard let error = transaction.error else { break }
                if let skError = error as? SKError.Code, skError == .paymentCancelled {
                    purchaseHandler(.canceled)
                } else {
                    purchaseHandler(.error(error))
                }
            case .restored:
                break
            case .purchasing:
                break
            case .deferred:
                break
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("- paymentQueueRestoreCompletedTransactionsFinished", queue)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("- ", queue, error)
    }
}
