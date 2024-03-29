//
//  RaffleInitializer.swift
//  Depo
//
//  Created by Ozan Salman on 26.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class RaffleInitializer: NSObject {
    class func initializeViewController(id: Int, url: String) -> RaffleViewController {
        let viewController = RaffleViewController(id: id, url: url)
        let configurator = RaffleConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
