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
        case facebookMessenger = "facebook.messenger"
        case outlook
        case mail
        case googlePhotos = "google.photos"
        case googleDrive = "google.drive"
        case weTransfer
        
        static var allKnownValues: [KnownApps] = [.whatsapp, .bip, .facebookMessenger, .twitter, .gmail, .googleDrive, .dropbox, .instagram, .facebook, .outlook, .mail, .drive, .googleDrive, .weTransfer]
    }
    
    func knownAppName() -> String {
        for value in KnownApps.allKnownValues {
            let valueString = value.rawValue.lowercased()
            if self.lowercased().contains(valueString) {
                return valueString.capitalized
            }
        }
        return KnownApps.other.rawValue.capitalized
    }
}
