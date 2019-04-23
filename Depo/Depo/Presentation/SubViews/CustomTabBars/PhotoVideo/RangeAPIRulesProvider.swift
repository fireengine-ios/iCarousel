//
//  RangeAPIRulesProvider.swift
//  Depo
//
//  Created by Konstantin Studilin on 23/04/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class RangeAPIInfoProviderInput {
    private(set) var date: Date?
    private(set) var id: Int64 = 0
    private(set) var isMissingDate = false
    private(set) var isLast = false
    private(set) var isFirst = false
    
    
    init(date: Date?, id: Int64, isLast: Bool = false, isFirst: Bool = false, isMissingDate: Bool = false) {
        self.date = date
        self.id = id
        self.isLast = isLast
        self.isFirst = isFirst
        self.isMissingDate = isMissingDate
    }
}


final class RangeAPIInfoProvider {
    
    private func rangeAPIInfo(top: RangeAPIInfoProviderInput, bottom: RangeAPIInfoProviderInput, scrollDirection: ScrollDirection) -> (start: RangeAPIInfo?, end: RangeAPIInfo?) {
        
        switch scrollDirection {
        case .down:
            if top.isMissingDate {
                return (RangeAPIInfo(date: nil, id: top.id), nil)
            }
            return (RangeAPIInfo(date: top.date, id: top.id), nil)
            
        case .up:
            if bottom.isMissingDate {
                return (nil, RangeAPIInfo(date: nil, id: bottom.id))
            }
            return (nil, RangeAPIInfo(date: bottom.date, id: bottom.id))
            
        case .none:
            return (RangeAPIInfo(date: top.date, id: top.id), RangeAPIInfo(date: bottom.date, id: bottom.id))
        }
    }
}
