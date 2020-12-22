//
//  InstagramParametrs.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class SocialStatusParametrs: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.socialStatus, relativeTo: super.patch)!
    }
}

final class InstagramConfigParametrs: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.instagramConfig, relativeTo: super.patch)!
    }
}

final class SocialSyncStatusParametrs: BaseRequestParametrs {
    
    let status: Bool
    
    init(status: Bool) {
        self.status = status
    }
    
    override var requestParametrs: Any {
        return status ? "true" : "false"
    }
    
    override var patch: URL {
        return URL(string: RouteRequests.instagramSyncStatus, relativeTo: super.patch)!
    }
}

final class SocialSyncStatusGetParametrs: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.instagramSyncStatus, relativeTo: super.patch)!
    }
}

final class CreateMigrationParametrs: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.instagramCreateMigration, relativeTo: super.patch)!
    }
}

final class CancelMigrationParametrs: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.instagramCancelMigration, relativeTo: super.patch)!
    }
}
