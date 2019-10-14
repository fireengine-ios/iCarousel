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
    
    typealias OfferAppleHandler = ResponseBool
    typealias PurchaseHandler = (_ isSuccess: PurchaseResult) -> Void
    
    private var restorePurchasesCallback: RestoreHandler?
    private var offerAppleHandler: OfferAppleHandler = {_ in }
    private var purchaseHandler: PurchaseHandler = {_ in }
    
    private var productsRequests = [SKRequest]()
    
    private var restoreInProgress = false
    private var purchaseInProgress = false
    
    private var isActivePurchases = false
    
    /// 2 arrays to separate active and inactive purchases and that they don't overwrite each other
    private var offered: [SKProduct]?
    private var activeProducts: [SKProduct]?
    
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
    
    func loadProducts(productIds: [String], isActivePurchases: Bool, handler: @escaping ResponseBool) {
        DispatchQueue.main.async {
            debugLog("IAPManager loadProductsWithProductIds")
            self.setActivePurchasesState(isActivePurchases)
            self.offerAppleHandler = handler
            let request = SKProductsRequest(productIdentifiers: Set(productIds))
            
            self.productsRequests.append(request)
            request.delegate = self
            request.start()
        }
    }
    
    func purchase(product: SKProduct, handler: @escaping PurchaseHandler) {
        debugLog("IAPManager purchase offer")
        
        guard canMakePayments else {
            debugLog("IAPManager can't make payments")
            return
        }
        
        guard !purchaseInProgress else {
            debugLog("IAPManager purchase in progress")
            handler(PurchaseResult.inProgress)
            return
        }
        
        purchaseHandler = handler
        purchaseInProgress = true
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases(restoreCallBack: @escaping RestoreHandler) {
        debugLog("IAPManager restorePurchases")
        
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
        let currentProducts = isActivePurchases ? activeProducts : offered
        guard let products = currentProducts else {
            return nil
        }
        
        return products.first(where: { $0.productIdentifier == productId })
    }
    
    func setActivePurchasesState(_ isActivePurchases: Bool) {
        self.isActivePurchases = isActivePurchases
    }
}

extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        debugLog("IAPManager Loaded list of products")
        
        if isActivePurchases {
            activeProducts = response.products
        } else {
            offered = response.products
        }
        
        offerAppleHandler(.success(true))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        debugLog("IAPManager Failed to load list of products")
        
        offerAppleHandler(.failed(error))
    
    func requestDidFinish(_ request: SKRequest) {
        guard let request = productsRequests.first(where: { $0 == request}) else {
            assertionFailure()
            return
        }
        request.delegate = nil
        productsRequests.remove(request)
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        debugLog("IAPManager paymentQueue updatedTransactions")
        
        guard !restoreInProgress else {
            return
        }
        
        var isPurchasing = false
        
        for transaction in transactions {
            debugLog("- transaction productIdentifier = \(transaction.payment.productIdentifier); state = \(transaction.transactionState)")
            switch transaction.transactionState {
            case .purchased: completeTransaction(transaction)
            case .failed: failedTransaction(transaction)
            case .restored: restoreTransaction(transaction)
            case .purchasing: isPurchasing = true
            default: break
            }
        }
        
        purchaseInProgress = isPurchasing
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        debugLog("IAPManager paymentQueueRestoreCompletedTransactionsFinished")
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
        debugLog("IAPManager paymentQueue restoreCompletedTransactionsFailedWithError")
        debugPrint("- restoreCompletedTransactionsFailedWithError", queue, error)
        
        restoreInProgress = false
        restorePurchasesCallback?(.fail(error))
    }
}

extension IAPManager {
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        debugLog("IAPManager completeTransaction...")
        
        if purchaseInProgress {
            if let type = MenloworksSubscriptionProductID(rawValue: transaction.payment.productIdentifier) {
                MenloworksAppEvents.onSubscriptionPurchaseCompleted(type)
            }
            purchaseHandler(.success(transaction.payment.productIdentifier))
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        debugLog("IAPManager failedTransaction...")
        
        if purchaseInProgress {
            let error = transactionError(for: transaction.error as NSError?)
            if error.code == .paymentCancelled {
                purchaseHandler(.canceled)
            } else {
                purchaseHandler(.error(error))
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        debugLog("IAPManager restoreTransaction...")
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func transactionError(for error: NSError?) -> SKError {
        let message = "Unknown error"
        let altError = NSError(domain: SKErrorDomain, code: SKError.unknown.rawValue, userInfo: [ NSLocalizedDescriptionKey: message ])
        let nsError = error ?? altError
        return SKError(_nsError: nsError)
    }
}
