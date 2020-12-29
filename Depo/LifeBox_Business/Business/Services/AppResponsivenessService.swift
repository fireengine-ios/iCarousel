//
//  AppResponsivenessService.swift
//  Depo
//
//  Created by Konstantin on 5/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class AppResponsivenessService {
    
    static let shared = AppResponsivenessService()
    
    private let widgetService = WidgetService()
    private let updateInterval = NumericConstants.intervalInSecondsBetweenAppResponsivenessUpdate
    
    
    private lazy var timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(saveMainAppLastUpdateDate), userInfo: nil, repeats: true)

    
    #if MAIN_APP
    func startMainAppUpdate() {
        timer.tolerance = updateInterval * 0.1
        timer.fire()
    }
    #endif
    
    func isMainAppResponsive() -> Bool {
        guard let lastUpdateDate = widgetService.mainAppResponsivenessDate else {
            return false
        }

        return Date().timeIntervalSince(lastUpdateDate) < updateInterval
    }
    
    @objc private func saveMainAppLastUpdateDate() {
        widgetService.mainAppResponsivenessDate = Date()
    }
    
}
