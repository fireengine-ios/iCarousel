//
//  IAPIntroPriceEligibilityChecker.swift
//  Depo
//
//  Created by Hady on 6/20/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 12.0, *)
struct IAPIntroPriceEligibilityChecker {
    
    static let shared = IAPIntroPriceEligibilityChecker()

    typealias ReceiveIntroEligibilityBlock = ([String: IAPIntroEligibilityStatus], Error?) -> Void

    private let receiptParser: ReceiptParser
    private let productsFetcher: IAPProductsFetcher

    init(
        receiptParser: ReceiptParser = ReceiptParser(),
        productsFetcher: IAPProductsFetcher = IAPProductsFetcher()
    ) {
        self.receiptParser = receiptParser
        self.productsFetcher = productsFetcher
    }

    func checkEligibility(with receiptData: Data,
                          productIdentifiers candidateProductIdentifiers: Set<String>,
                          completion: @escaping ReceiveIntroEligibilityBlock) {
        guard candidateProductIdentifiers.count > 0 else {
            completion([:], nil)
            return
        }
        debugLog("Checking introductory offer eligibility")

        var result = candidateProductIdentifiers.reduce(into: [:]) { resultDict, productId in
            resultDict[productId] = IAPIntroEligibilityStatus.unknown
        }
        do {
            let receipt = try receiptParser.parse(from: receiptData)
            let purchasedProductIdsWithIntroOffersOrFreeTrials = receipt.purchasedIntroOfferOrFreeTrialProductIdentifiers()
            let allProductIdentifiers = candidateProductIdentifiers.union(purchasedProductIdsWithIntroOffersOrFreeTrials)

            productsFetcher.fetchProducts(withIdentifiers: allProductIdentifiers) { allProducts in
                let purchasedProductsWithIntroOffersOrFreeTrials = allProducts.filter {
                    purchasedProductIdsWithIntroOffersOrFreeTrials.contains($0.productIdentifier)
                }
                let candidateProducts = allProducts.filter {
                    candidateProductIdentifiers.contains($0.productIdentifier)
                }

                let eligibility = self.checkEligibility(
                    candidateProducts: candidateProducts,
                    purchasedProductsWithIntroOffers: purchasedProductsWithIntroOffersOrFreeTrials)
                result.merge(eligibility) { (_, new) in new }

                debugLog("Checking introductory offer eligibility - result: \(result)")
                completion(result, nil)
            }
        } catch {
            debugLog("Failed parsing receipt locally: \(error)")
            completion([:], error)
        }
    }

    private func checkEligibility(candidateProducts: [SKProduct],
                                  purchasedProductsWithIntroOffers: [SKProduct]) -> [String: IAPIntroEligibilityStatus] {
        var result: [String: IAPIntroEligibilityStatus] = [:]

        for candidate in candidateProducts {
            guard candidate.subscriptionPeriod != nil else {
                result[candidate.productIdentifier] = .unknown
                continue
            }
            let usedIntroForProductIdentifier = purchasedProductsWithIntroOffers
                .contains { purchased in
                    let foundByGroupId = (candidate.subscriptionGroupIdentifier != nil
                        && candidate.subscriptionGroupIdentifier == purchased.subscriptionGroupIdentifier)
                    return foundByGroupId
                }

            if candidate.introductoryPrice == nil {
                result[candidate.productIdentifier] = .noIntroOfferExists
            } else {
                result[candidate.productIdentifier] = usedIntroForProductIdentifier ? .ineligible : .eligible
            }
        }
        return result
    }

}
