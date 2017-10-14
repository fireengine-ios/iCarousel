//
//  DateExtension.swift
//  Depo
//
//  Created by Oleg on 30.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol Components {
    
    func getYear()->Int
    
    func getMonth()->Int
}

extension Date: Components {
    
    func getYear()->Int{
        let calendar = Calendar.current
        
        return calendar.component(.year, from: self)
    }
    
    func getMonth()->Int{
        let calendar = Calendar.current
        
        return calendar.component(.month, from: self)
    }
    
    func getDateInTextForCollectionViewHeader()->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self)
    }
    
    func getDateForSortingOfCollectionView() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM"
        return formatter.string(from: self)
    }
    
    func getDateInFormat(format: String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var withoutSeconds: Date {
        let time = floor(timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }
}
