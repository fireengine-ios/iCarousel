//
//  DrawCampaignInitializer.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class DrawCampaignInitializer: NSObject {
    class func initializeViewController(campaignId: Int) -> DrawCampaignViewController {
        let viewController = DrawCampaignViewController(campaignId: campaignId)
        let configurator = DrawCampaignConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
