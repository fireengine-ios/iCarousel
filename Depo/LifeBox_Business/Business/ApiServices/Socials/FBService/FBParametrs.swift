//
//  FBParametrs.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/6/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class FBPermissions: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.fbPermissions, relativeTo: super.patch)!
    }
}

class FBConnect: BaseRequestParametrs {
    
    private let token: String
    
    override var patch: URL {
        let patch = String(format: RouteRequests.fbConnect, token)
        return URL(string: patch, relativeTo: super.patch)!
    }
    
    init(withToken token: String) {
        self.token = token
    }
}

class FBStatus: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.fbStatus, relativeTo: super.patch)!
    }
}

class FBStart: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.fbStart, relativeTo: super.patch)!
    }
}

class FBStop: BaseRequestParametrs { 
    override var patch: URL {
        return URL(string: RouteRequests.fbStop, relativeTo: super.patch)!
    }
}
