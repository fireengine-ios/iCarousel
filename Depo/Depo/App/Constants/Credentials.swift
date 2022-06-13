//
//  Credentials.swift
//  Depo
//
//  Created by Burak Donat on 22.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

struct Credentials {
    static let googleServerClientID: String = {
        if RouteRequests.isBillo {
            return "487629516002-0q99omhe2apgrb1p7vosg1sjq51mem5r.apps.googleusercontent.com"
        } else {
            #if APPSTORE
            return "590528416223-1a8dnpgid8b9gg96dqphop895tk8osur.apps.googleusercontent.com"
            #else
            return "685338462870-flqbnde1f2gdolak5hv9769aui2vh6nk.apps.googleusercontent.com"
            #endif
        }
    }()
}
