//
//  XCGLogger+Extension.swift
//  Depo
//
//  Created by Konstantin on 5/4/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import XCGLogger


extension XCGLogger {
    static var lifeboxLogFileName: String {
        return "app.log"
    }
    
    static var lifeboxAdvancedLoggerIdentifier: String {
        return "lifebox.advancedLogger"
    }
    
    static var lifeboxFileDestinationIdentifier: String {
        return "lifebox.advancedLogger.fileDestination"
    }
    
    static var lifeboxAppendMarker: String {
        return "-- Relaunched App --"
    }
}
