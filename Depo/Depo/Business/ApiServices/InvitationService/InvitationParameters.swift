//
//  InvitationParameters.swift
//  Depo
//
//  Created by Alper Kırdök on 7.06.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

struct InvitationSubscriptionPath {
    static let invitationSubscriptions = "invitation/subscriptions"
}

class InvitationParameters: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: InvitationSubscriptionPath.invitationSubscriptions, relativeTo: super.patch)!
    }
}
