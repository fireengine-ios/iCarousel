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
    
    class PhotoUpload: MenloworksIsWiFiTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.photoUpload, isWiFi: isWiFi)
        }
    }
    
    class WiFi3G: MenloworksIsWiFiTag {
        init(isWiFi: Bool) {
            super.init(name: NameConstants.wifi3g, isWiFi: isWiFi)
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

class MenloworksIsWiFiTag: MenloworksTag {
    init(name: String, isWiFi: Bool) {
        super.init(name: name,
                   value: isWiFi ? MenloworksTags.ValueConstants.wifi : MenloworksTags.ValueConstants.mobile)
    }
}

class MenloworksBoolTag: MenloworksTag {
    init(name: String, value: Bool) {
        super.init(name: name,
                   value: value ? MenloworksTags.ValueConstants.true : MenloworksTags.ValueConstants.false)
    }
}

class MenloworksPermissionTag: MenloworksTag {
    init(name: String, isGranted: Bool) {
        super.init(name: name,
                   value: isGranted ? MenloworksTags.ValueConstants.granted : MenloworksTags.ValueConstants.denied)
    }
}
