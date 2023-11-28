//
//  DateExtension.swift
//  Depo
//
//  Created by Oleg on 30.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol Components {
    
    func getYear() -> Int
    
    func getMonth() -> Int
}

extension Date: Components {
    
    func getYear() -> Int {
        let calendar = Calendar.current
        
        return calendar.component(.year, from: self)
    }
    
    func getMonth() -> Int {
        let calendar = Calendar.current
        
        return calendar.component(.month, from: self)
    }
    
    func getDateInTextForCollectionViewHeader() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self)
    }
    
    func getDateInTextForScrollBar() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL yyyy"
        return formatter.string(from: self)
    }
    
    func getDateForSortingOfCollectionView() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM"
        return formatter.string(from: self)
    }
    
    func getDateInFormat(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func getMonthsBetweenDateAndCurrentDate() -> Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
    }

    func isInRange(start: Date, end: Date) -> Bool {
        guard end >= start else { return false }
        return (start...end).contains(self)
    }
    
    var withoutSeconds: Date {
        let time = floor(timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }
    
    var millisecondsSince1970: Int64 {
        return (timeIntervalSince1970 * 1000.0).asInt64 ?? 0
    }
    
    static func from(string: String) -> Date? {
        guard let timeInterval = Double(string) else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    static func from(millisecondsSince1970: Double) -> Date {
        return Date(timeIntervalSince1970: millisecondsSince1970 / 1000.0)
    }
    
    func createCurrentDate() -> String {
        let date = getDateInFormat(format: "yyyy-MM-dd")
        return date
    }
    
    func createCurrentDateNonChar() -> String {
        let date = getDateInFormat(format: "yyyyMMdd")
        return date
    }
    
    func createCurrentHour() -> String {
        let hour = getDateInFormat(format: "HHmm")
        return hour
    }
    
    func currentYear() -> String {
        let year = getDateInFormat(format: "yyyy")
        return year
    }
}
