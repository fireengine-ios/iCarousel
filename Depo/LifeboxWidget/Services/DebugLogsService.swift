//
//  DebugLogsService.swift
//  LifeboxWidgetExtension
//
//  Created by Konstantin Studilin on 08.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import XCGLogger


extension XCGLogger {
    static var homeWidgetLogFileName: String {
        return "home_widget.log"
    }
    
    static var homeWidgetLoggerIdentifier: String {
        return "lifebox.advancedLogger"
    }
    
    static var homeWidgetFileDestinationIdentifier: String {
        return "lifeboxHomeWidget.advancedLogger.fileDestination"
    }
    
    static var homeWidgetAppendMarker: String {
        return "-- Relaunched App --"
    }
}

final class DebugLogService {
    
    private static let log: XCGLogger = {
        let log = XCGLogger(identifier: XCGLogger.homeWidgetLoggerIdentifier, includeDefaultDestinations: false)
        
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.groupIdentifier)
        let logPath = groupURL!.appendingPathComponent(XCGLogger.homeWidgetLogFileName)
        
        let autoRotatingFileDestination = AutoRotatingFileDestination(owner: log,
                                                                      writeToFile: logPath,
                                                                      identifier: XCGLogger.homeWidgetLoggerIdentifier,
                                                                      shouldAppend: true,
                                                                      appendMarker: XCGLogger.homeWidgetAppendMarker,
                                                                      attributes: [.protectionKey : FileProtectionType.completeUntilFirstUserAuthentication],
                                                                      maxFileSize: NumericConstants.logMaxSize,
                                                                      maxTimeInterval: NumericConstants.logDuration,
                                                                      archiveSuffixDateFormatter: nil)
        autoRotatingFileDestination.outputLevel = .debug
        autoRotatingFileDestination.showLogIdentifier = true
        autoRotatingFileDestination.showFunctionName = true
        autoRotatingFileDestination.showThreadName = true
        autoRotatingFileDestination.showLevel = true
        autoRotatingFileDestination.showFileName = true
        autoRotatingFileDestination.showLineNumber = true
        autoRotatingFileDestination.showDate = true
        autoRotatingFileDestination.logQueue = XCGLogger.logQueue
        
        log.add(destination: autoRotatingFileDestination)
        
        log.logAppDetails()
        
        return log
    }()
    
    
    static func debugLog(_ string: String, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line) {
        log.debug(string, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }
}
