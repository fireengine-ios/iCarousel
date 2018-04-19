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
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!.stringByAppendingPathComponent(path: "Temp")
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        return path
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
    
    static func getFreeDiskSpaceInBytes() -> Int64? {
        var freeSize: Int64?
        if #available(iOS 11.0, *) {
            let fileURL = URL(fileURLWithPath:Device.homeFolderString())
            do {
                let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                freeSize = values.volumeAvailableCapacityForImportantUsage
            } catch {
                print(error.localizedDescription)
            }
        }
        return freeSize ?? getFreeDiskSpaceInBytesIOS10()
    }
    
    static private func getFreeDiskSpaceInBytesIOS10() -> Int64? {
        var freeSize: NSNumber?
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString())
            freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        } catch {
            print(error.localizedDescription)
        }
        return freeSize?.int64Value
    }
    
    static func getTotalDiskSpace() -> Int64? {
        var totalSpace: NSNumber?
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString())
            totalSpace = dict[.systemSize] as? NSNumber
        } catch {
            print(error.localizedDescription)
        }
        return totalSpace?.int64Value
    }
    
    static var getFreeDiskSpaceInPercent: Double {
        guard let freeSpace = getFreeDiskSpaceInBytes(),
            let totalSpace = getTotalDiskSpace() else {
            return 0
        }
        return Double(freeSpace)/Double(totalSpace)
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
