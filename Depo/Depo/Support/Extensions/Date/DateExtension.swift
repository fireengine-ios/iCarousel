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
    
    func getTimeIntervalBetweenDateAndCurrentDate() -> Int {
        let curentDate = Date()
        let deltaDate = curentDate - self.timeIntervalSince1970
        let calendar = Calendar.current
        
        let years = calendar.component(.year, from: deltaDate) - 1970
        let monthes = calendar.component(.month, from: deltaDate) - 1
        return monthes + years * 12
    }
    
    var withoutSeconds: Date {
        let time = floor(timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }
    
    var millisecondsSince1970: UInt {
        return UInt((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
