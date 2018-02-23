//
//  MenloworksTags.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class MenloworksTags {
    class Tutorial: MenloworksTag {
        init() {
            super.init(name: NameConstants.tutorial)
        }
    }
    
    class PhotoUpload: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.photoUpload, value: isWiFi, boolType: .wifi)
        }
    }
    
    class WiFi3G: MenloworksBoolTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.wifi3g, value: isWiFi, boolType: .wifi)
        }
    }
    
    class MusicUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.musicUpload)
        }
    }
    
    class VideoUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.videoUpload)
        }
    }
    
    class FileUpload: MenloworksTag {
        init() {
            super.init(name: NameConstants.fileUpload)
        }
    }
    
    class LoggedIn: MenloworksBoolTag {
        init(isLoggedIn: Bool) {
            super.init(name: NameConstants.loggedIn, value: isLoggedIn, boolType: .yesNo)
        }
    }
    
    class LogginCompleted: MenloworksTag {
        init() {
            super.init(name: NameConstants.loginCompleted)
        }
    }
    
    class SignUpCompleted: MenloworksTag {
        init() {
            super.init(name: NameConstants.signupCompleted)
        }
    }
}

class MenloworksTag {
    let name: String
    let value: String?
    
    private init() {
        name = ""
        value = nil
    }
    
    init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

class MenloworksBoolTag: MenloworksTag {
    enum BoolType {
        case trueFalse
        case yesNo
        case onOff
        case permission
        case wifi
    }
    
    init(name: String, value: Bool, boolType: BoolType) {
        let stringValue: String
        switch boolType {
        case .trueFalse:
            stringValue = value ? MenloworksTags.ValueConstants.true : MenloworksTags.ValueConstants.false
        case .yesNo:
            stringValue = value ? MenloworksTags.ValueConstants.yes : MenloworksTags.ValueConstants.no
        case .onOff:
            stringValue = value ? MenloworksTags.ValueConstants.on : MenloworksTags.ValueConstants.off
        case .permission:
            stringValue = value ? MenloworksTags.ValueConstants.granted : MenloworksTags.ValueConstants.denied
        case .wifi:
            stringValue = value ? MenloworksTags.ValueConstants.wifi : MenloworksTags.ValueConstants.mobile
        }
        
        super.init(name: name, value: stringValue)
    }
}

class MenloworksPermissionTag: MenloworksTag {
    init(name: String, isGranted: Bool) {
        super.init(name: name,
                   value: isGranted ? MenloworksTags.ValueConstants.granted : MenloworksTags.ValueConstants.denied)
    }
}
