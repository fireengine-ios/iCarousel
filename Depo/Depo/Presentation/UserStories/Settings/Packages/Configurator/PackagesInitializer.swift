//
//  PackagesPackagesInitializer.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class PackagesModuleInitializer: NSObject {
    static func viewController(quotaInfo: QuotaInfoResponse? = nil, affiliate: String? = nil) -> PackagesViewController {
        let viewController = PackagesViewController()
        let configurator = PackagesModuleConfigurator()
        configurator.configure(viewController: viewController, quotaInfo: quotaInfo, affiliate: affiliate)
        return viewController
    }
}
