//
//  SKProductSubscriptionPeriodFormatter.swift
//  Depo
//
//  Created by Hady on 9/13/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import StoreKit

@available(iOS 11.2, *)
final class ProductSubscriptionPeriodFormatter {
    
    static let shared = ProductSubscriptionPeriodFormatter()
    
    private let dateComponentFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter
    }()

    /// Formats a given `SKProductSubscriptionPeriod` into a localized period string
    func string(from period: SKProductSubscriptionPeriod, numberOfPeriods: Int = 1) -> String? {
        // Return "Month" / "Day" / etc.. for a single units
        let numberOfUnits = period.numberOfUnits * numberOfPeriods
        if numberOfUnits == 1 {
            return period.unit.localized
        }

        // Return "6 months" / "15 days" / etc..
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        switch period.unit {
        case .day:
            dateComponents.setValue(numberOfUnits, for: .day)
        case .week:
            dateComponents.setValue(numberOfUnits, for: .weekOfMonth)
        case .month:
            dateComponents.setValue(numberOfUnits, for: .month)
        case .year:
            dateComponents.setValue(numberOfUnits, for: .year)
        @unknown default:
            debugLog("unknown SKProduct.PeriodUnit \(self)")
            return nil
        }

        dateComponentFormatter.allowedUnits = [period.unit.calendarUnit]
        return dateComponentFormatter.string(from: dateComponents)
    }
}

@available(iOS 11.2, *)
private extension SKProduct.PeriodUnit {
    var localized: String? {
        switch self {
        case .day:
            return TextConstants.packagePeriodDay
        case .week:
            return TextConstants.packagePeriodWeek
        case .month:
            return TextConstants.packagePeriodMonth
        case .year:
            return TextConstants.packagePeriodYear
        @unknown default:
            debugLog("unknown SKProduct.PeriodUnit \(self)")
        }
        return nil
    }

    var calendarUnit: NSCalendar.Unit {
        switch self {
        case .day:
            return .day
        case .week:
            return .weekOfMonth
        case .month:
            return .month
        case .year:
            return .year
        @unknown default:
            debugLog("unknown SKProduct.PeriodUnit \(self)")
        }
        return .day
    }
}
