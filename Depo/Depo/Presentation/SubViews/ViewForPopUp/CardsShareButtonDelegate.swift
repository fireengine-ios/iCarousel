//
//  CardsShareButtonMulticastDelegate.swift
//  Depo
//
//  Created by Maxim Soldatov on 8/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum ShareType {
    case link
    case origin
    
    var isOrigin: Bool {
        return self == .origin
    }
}

protocol CardsShareButtonDelegate: class {
    func share(item: BaseDataSourceItem, type: ShareType)
}

