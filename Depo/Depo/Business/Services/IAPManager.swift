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
    
    typealias OfferAppleHandler = ResponseArrayHandler<OfferApple>
    typealias PurchaseHandler = (_ isSuccess: PurchaseResult) -> Void
    
    private var restorePurchasesCallback: RestoreHandler?
    private var offerAppleHandler: OfferAppleHandler = {_ in }
    private var purchaseHandler: PurchaseHandler = {_ in }
    
    private var restoreInProgress = false
    private var purchaseInProgress = false
    
    private var products: [SKProduct]?
    
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
        
        guard !purchaseInProgress else {
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
    
    func product(for productId: String) -> SKProduct? {
        guard let products = products else {
            return nil
        }
        
        return products.first(where: { $0.productIdentifier == productId })
    }
}

extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        log.debug("IAPManager Loaded list of products")
        
        products = response.products
        
        let sortedOffers = response.products
            .map { OfferApple(skProduct: $0) }
            .sorted { $0.rawPrice < $1.rawPrice }
        offerAppleHandler(.success(sortedOffers))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        log.debug("IAPManager Failed to load list of products")
        
        offerAppleHandler(.failed(error))
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        log.debug("IAPManager paymentQueue updatedTransactions")
        
        guard !restoreInProgress else {
            return
        }
        
        var isPurchasing = false
        
        for transaction in transactions {
            log.debug("- transaction productIdentifier = \(transaction.payment.productIdentifier); state = \(transaction.transactionState)")
            switch transaction.transactionState {
            case .purchased: completeTransaction(transaction)
            case .failed: failedTransaction(transaction)
            case .restored: restoreTransaction(transaction)
            case .purchasing: isPurchasing = true
            default: break
            }
        }
        
        purchaseInProgress = !isPurchasing
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
