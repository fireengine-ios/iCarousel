//
//  MenloworksAppEvents.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class MenloworksAppEvents {
    static func onTutorial() {
        MenloworksTagsService.shared.onTutorial()
    }
    
    static func onFileUploadedWithType(_ type: FileType) {
        MenloworksTagsService.shared.onFileUploadedWithType(type)
    }
    
    static func onLogin() {
        MenloworksTagsService.shared.onLogin()
    }
    
    static func onStartWithLogin(_ isLoggedIn: Bool) {
        MenloworksTagsService.shared.onStartWithLogin(isLoggedIn)
    }
    
    static func onSignUp() {
        MenloworksTagsService.shared.onSignUp()
    }
}
