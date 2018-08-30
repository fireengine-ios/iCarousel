//
//  SubscriptionParameters.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

struct SubscriptionPath {
    static let activeSubscription = "account/activeSubscriptionList"
//    static let currentSubscription = "/api/account/currentSubscription" /// MAYBE WILL BE NEED
//    static let cancelSubscription = "/api/account/cancelSubscription" /// MAYBE WILL BE NEED
}

class ActiveSubscriptionParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: SubscriptionPath.activeSubscription, relativeTo: super.patch)!
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
