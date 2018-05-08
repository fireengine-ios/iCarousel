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
    
    private var restoreInProgress = false
    private var purchaseInProgress = false
    
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
        
        guard canMakePayments else {
            log.debug("IAPManager can't make payments")
            return
        }
        
        guard purchaseInProgress else {
            log.debug("IAPManager purchase in progress")
            handler(PurchaseResult.inProgress)
            return
        }
        
        purchaseHandler = handler
        purchaseInProgress = true
        let payment = SKPayment(product: offerApple.skProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases(restoreCallBack: @escaping RestoreHandler) {
        log.debug("IAPManager restorePurchases")
        
        restorePurchasesCallback = restoreCallBack
        restoreInProgress = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    var receipt: String? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl)
            else { return nil }
        return receiptData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
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
        
        guard !restoreInProgress else {
            return
        }
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased: completeTransaction(transaction)
            case .failed: failedTransaction(transaction)
            case .restored: restoreTransaction(transaction)
            default: break
            }
        }
        
        purchaseInProgress = false
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
        restoreInProgress = false
        restorePurchasesCallback?(.success(purchasedIDs))
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        log.debug("IAPManager paymentQueue restoreCompletedTransactionsFailedWithError")
        debugPrint("- restoreCompletedTransactionsFailedWithError", queue, error)
        
        restoreInProgress = false
        restorePurchasesCallback?(.fail(error))
    }
}

extension IAPManager {
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        log.debug("IAPManager completeTransaction...")
        
        if purchaseInProgress {
            if let type = MenloworksSubscriptionProductID(rawValue: transaction.payment.productIdentifier) {
                MenloworksAppEvents.onSubscriptionPurchaseCompleted(type)
            }
            purchaseHandler(.success(transaction.payment.productIdentifier))
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        log.debug("IAPManager failedTransaction...")
        
        if purchaseInProgress, let error = transaction.error {
            if let skError = error as? SKError.Code, skError == .paymentCancelled {
                purchaseHandler(.canceled)
            } else {
                purchaseHandler(.error(error))
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        log.debug("IAPManager restoreTransaction...")
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
