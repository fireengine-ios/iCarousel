//
//  Factory.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/16/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

let factory: Factory = FactoryMain()

protocol Factory {
    func resolve() -> MediaPlayer
    func resolve() -> DropboxManager
    func resolve() -> PasscodeStorage
    func resolve() -> BiometricsManager
}

final class FactoryMain: NSObject, Factory {
    @objc static let mediaPlayer = MediaPlayer() /// when will be appdelegate on swift, make it private
    func resolve() -> MediaPlayer {
        return FactoryMain.mediaPlayer
    }
    
    
    private static let dropboxManager = DropboxManager()
    func resolve() -> DropboxManager {
        return FactoryMain.dropboxManager
    }
    
    private static let passcodeStorage = PasscodeStorageDefaults()
    func resolve() -> PasscodeStorage {
        return FactoryMain.passcodeStorage
    }
    
    private static let biometricsManager = BiometricsManagerImp()
    func resolve() -> BiometricsManager {
        return FactoryMain.biometricsManager
    }
}
