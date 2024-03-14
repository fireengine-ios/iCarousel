//
//  SubscriptionParameters.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

struct SubscriptionPath {
    static let activeSubscription = "v2/account/activeSubscriptionList?includeSardisSubscriptions=false&includeSardisPrice=false"
    static let activeSubscriptionV2 = "v2/account/activeSubscriptionList?includeSardisSubscriptions=true&includeSardisPrice=true"
//    static let currentSubscription = "/api/account/currentSubscription" /// MAYBE WILL BE NEED
//    static let cancelSubscription = "/api/account/cancelSubscription" /// MAYBE WILL BE NEED
}

class ActiveSubscriptionParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: SubscriptionPath.activeSubscription, relativeTo: super.patch)!
    }
}
class ActiveSubscriptionV2Parameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: SubscriptionPath.activeSubscriptionV2, relativeTo: super.patch)!
    }
}
/// MAYBE WILL BE NEED
//class CurrentSubscriptionParameters: BaseRequestParametrs {
//    override var patch: URL {
//        return URL(string: SubscriptionPath.currentSubscription, relativeTo: super.patch)!
//    }
//}

/// MAYBE WILL BE NEED
//class CancelSubscriptionParameters: BaseRequestParametrs {
//    override var patch: URL {
//        return URL(string: SubscriptionPath.cancelSubscription, relativeTo: super.patch)!
//    }
//}
