//
//  RangeAPIInfo.swift
//  Depo
//
//  Created by Konstantin Studilin on 17/04/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation


final class RangeAPIInfo {
    private(set) var date: Date = .distantPast
    private(set) var id: Int64?
    
    init(date: Date, id: Int64?) {
        self.date = date
        self.id = id
    }
}
