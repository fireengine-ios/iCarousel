//
//  CardsShareButtonMulticastDelegate.swift
//  Depo
//
//  Created by Maxim Soldatov on 8/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

enum CardShareType {
    case link
    case origin
    case videoOrigin
    
    var isOrigin: Bool {
        return self == .origin
    }
}

protocol CardsShareButtonDelegate: AnyObject {
    func share(item: BaseDataSourceItem, type: CardShareType)
}

