//
//  DrawCampaignInitializer.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class DrawCampaignInitializer: NSObject {
    class func initializeViewController(campaignId: Int, endDate: String, title: String) -> DrawCampaignViewController {
        let viewController = DrawCampaignViewController(campaignId: campaignId, endDate: endDate, title: title)
        let configurator = DrawCampaignConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
