//
//  WidgetService.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import MMWormhole


final class WidgetService {
    
    let shared = WidgetService()
    
    private lazy var wormhole: MMWormhole = {
        return MMWormhole(applicationGroupIdentifier: "group.com.turkcell.akillidepo", optionalDirectory: "EXTENSION_WORMHOLE_DIR")
    }()
    
    
    func notifyWidgetAbout(_ synced: Int, of total: Int) {
        
    }
}
