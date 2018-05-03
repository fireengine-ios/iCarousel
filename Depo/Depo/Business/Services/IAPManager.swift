//
//  IAPManager.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/27/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import StoreKit

enum ProductRestoreCallBack {
    case success(Set<String>)
    case fail(Error)
}

typealias RestoreHandler = (_ productCallBack: ProductRestoreCallBack) -> ()

final class IAPManager: NSObject {
    
    static let shared = IAPManager()
    
    typealias OfferAppleHandler = ([OfferApple]) -> Void
    typealias PurchaseHandler = (_ isSuccess: PurchaseResult) -> Void
    
    private var restorePurchasesCallback: RestoreHandler?
    private var offerAppleHandler: OfferAppleHandler = {_ in }
    private var purchaseHandler: PurchaseHandler = {_ in }
    
    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    override private init() {
        super.init()
        setupSKPaymentQueue()
    }
    
    private func setupSKPaymentQueue() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().transactions.forEach { transaction in
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func loadProducts(productIds: [String], handler: @escaping OfferAppleHandler) {
        log.debug("IAPManager loadProductsWithProductIds")
        
        offerAppleHandler = handler
        let request = SKProductsRequest(productIdentifiers: Set(productIds))
        request.delegate = self
        request.start()
    }
    
    func purchase(offerApple: OfferApple, handler: @escaping PurchaseHandler) {
        log.debug("IAPManager purchase offer")
        
        if !canMakePayments { return }
        purchaseHandler = handler
        let payment = SKPayment(product: offerApple.skProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases(restoreCallBack: @escaping RestoreHandler) {
        log.debug("IAPManager restorePurchases")
        
        restorePurchasesCallback = restoreCallBack
        SKPaymentQueue.default().restoreCompletedTransactions()
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
        log.debug("IAPManager productsRequest didReceive response")
        
        let sortedOffers = response.products
            .map { OfferApple(skProduct: $0) }
            .sorted { $0.rawPrice < $1.rawPrice }
        offerAppleHandler(sortedOffers)
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        log.debug("IAPManager paymentQueue updatedTransactions")
        
        var restoredIds: Set<String> = []
        var restoreError: Error? = nil
        
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
                restoredIds.insert(transaction.payment.productIdentifier)
                
                if let error = transaction.error {
                    restoreError = error
                }
            case .purchasing:
                break
            case .deferred:
                break
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        if !restoredIds.isEmpty {
            restorePurchasesCallback?(.success(restoredIds))
        } else if let error = restoreError {
            restorePurchasesCallback?(.fail(error))
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        log.debug("IAPManager paymentQueueRestoreCompletedTransactionsFinished")
        debugPrint("- paymentQueueRestoreCompletedTransactionsFinished", queue)
        
        var purchasedIDs: Set<String> = []
        queue.transactions.forEach { transaction in
            let productId = transaction.payment.productIdentifier
            purchasedIDs.insert(productId)
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        restorePurchasesCallback?(.success(purchasedIDs))
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        log.debug("IAPManager paymentQueue restoreCompletedTransactionsFailedWithError")
        debugPrint("- ", queue, error)
        restorePurchasesCallback?(.fail(error))
    }
}
