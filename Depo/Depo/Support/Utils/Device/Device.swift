//
//  Device.swift
//  Depo
//
//  Created by Alexander Gurin on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit

class Device {
    
    static func getFreeDiskSpaceInBytes() -> Int64? {
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString()),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
            else {
                return nil
        }
        return freeSize.int64Value
    }

    static private let supportedLanguages = ["tr", "en", "uk", "ru", "de", "ar", "ro", "es"]
    static private let defaultLocale = "en"
    
    static func documentsFolderUrl(withComponent: String ) -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask).last
        return documentsUrl!.appendingPathComponent(withComponent)

    }

    static func tmpFolderUrl(withComponent: String ) -> URL {
        let url = Device.tmpFolderString().appending("/").appending(withComponent)
        return URL(fileURLWithPath: url )
    }
    
    static func tmpFolderString() -> String {
        
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
    }
    
    static func homeFolderString() -> String {
        
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }
    
    /// https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
    static var isIphoneX: Bool {
        return (UIDevice.current.userInterfaceIdiom == .phone) && (UIScreen.main.nativeBounds.height == 2436)
    }
    
    static var isIpad: Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    static func operationSystemVersionLessThen(_ version: Int) -> Bool {
        return ProcessInfo().operatingSystemVersion.majorVersion < version
    }
    
    static var getFreeDiskSpaceInPercent: Double {
        var totalFreeSpace: Double = 0
        var totalSpace: Double = 0
        
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString())
            
            totalFreeSpace = (dict[.systemFreeSize] as! NSNumber).doubleValue
            totalSpace = (dict[.systemSize] as! NSNumber).doubleValue
            
        } catch {
            print("Can't calculate file size")
        }
        let t = totalFreeSpace / totalSpace
        return t
    }
    
    static var deviceInfo: [String: Any] {
        
        var result: [String: Any] = [:]
        let device = UIDevice.current
        
        if let uuid = device.identifierForVendor?.uuidString {
            result["uuid"] = uuid
        }
        result["name"] = device.name
        result["deviceType"] = isIpad ? "IPAD":"IPHONE"
        return result
    }
    
    static var locale: String {
        guard let preferedLanguage = Locale.preferredLanguages.first else {
            return defaultLocale
        }
        return String(preferedLanguage[..<String.Index(encodedOffset: 2)])
    }
    
    static var supportedLocale: String {
        let locale = Device.locale
        if supportedLanguages.contains(locale) {
            return locale
        } else {
            return defaultLocale
        }
    }
    
    static var winSize = UIScreen.main.bounds
}
