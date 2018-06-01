//
//  String+ShareActivity.swift
//  Depo
//
//  Created by Konstantin on 6/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


extension String {
    
    enum KnownApps: String {
        case whatsapp
        case bip
        case facebook
        case twitter
        case gmail
        case drive
        case dropbox
        case instagram
        case other
        
        static var allKnownValues: [KnownApps] = [.whatsapp, .bip, .facebook, .twitter, .gmail, .drive, .dropbox, .instagram]
    }
    
    func knownAppName() -> String {
        for value in KnownApps.allKnownValues {
            let valueString = value.rawValue
            if self.lowercased().contains(valueString) {
                return valueString.capitalized
            }
        }
        return KnownApps.other.rawValue.capitalized
    }
}
