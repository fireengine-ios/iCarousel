//
//  BrandAmbassadorDeeplinkHandler.swift
//  Depo
//
//  Created by yilmaz edis on 7.12.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class BrandAmbassadorDeeplinkHandler: DeeplinkHandlerProtocol {
    
    private var root: RouterVC!
    init(root: RouterVC) {
        self.root = root
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString == "akillidepo://markaelcisi"
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        let payCell = root.paycellCampaign()
        root?.pushViewController(viewController: payCell)
    }
}
