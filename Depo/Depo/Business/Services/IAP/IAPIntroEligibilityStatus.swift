//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  IntroEligibility.swift
//
//  Created by Joshua Liebowitz on 7/6/21.
//

import Foundation

/**
 * Enum of different possible states for intro price eligibility status.
 * * ``IntroEligibilityStatus/unknown`` RevenueCat doesn't have enough information to determine eligibility.
 * * ``IntroEligibilityStatus/ineligible`` The user is not eligible for a free trial or intro pricing for this
 * product.
 * * ``IntroEligibilityStatus/eligible`` The user is eligible for a free trial or intro pricing for this product.
 */
enum IAPIntroEligibilityStatus: Int {

    /**
     RevenueCat doesn't have enough information to determine eligibility.
     */
    case unknown = 0

    /**
     The user is not eligible for a free trial or intro pricing for this product.
     */
    case ineligible

    /**
     The user is eligible for a free trial or intro pricing for this product.
     */
    case eligible

    /**
     There is no free trial or intro pricing for this product.
     */
    case noIntroOfferExists

}
