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
    
    static let groupIdentifier = SharedConstants.groupIdentifier
    
    static let applicationId = "665036334"
    
    static private let supportedLanguages = ["tr", "en", "uk", "ru", "de", "ar", "ro", "es", "sq", "fr"]
    static private let defaultLocale = "en"
    
    static func documentsFolderUrl(withComponent: String) -> URL {
        let documentsUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return documentsUrls[documentsUrls.endIndex - 1].appendingPathComponent(withComponent)
    }
    
    static func sharedContainerUrl(withComponent: String) -> URL? {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        return container?.appendingPathComponent(withComponent)
    }

    static func tmpFolderUrl(withComponent: String ) -> URL {
        let url = Device.tmpFolderString().appending("/").appending(withComponent)
        return URL(fileURLWithPath: url)
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
    
    static var isIOS13: Bool {
        var isIOS13 = false
        
        if #available(iOS 13.0, *) {
            isIOS13 = true
        }
        
        return isIOS13
    }
    
    /// https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
    static var isIphoneX: Bool {
        return (UIDevice.current.userInterfaceIdiom == .phone) && (UIScreen.main.bounds.height >= 812)
    }
    
    static var isIpad: Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    static var deviceType: String {
        return isIpad ? "IPAD" : "IPHONE"
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    static func operationSystemVersionLessThen(_ version: Int) -> Bool {
        return ProcessInfo().operatingSystemVersion.majorVersion < version
    }
    
    static func getFreeDiskSpaceInBytes() -> Int64 {
        if #available(iOS 11.0, *) {
            return getFreeDiskSpaceInBytesIOS11()
        } else {
            return getFreeDiskSpaceInBytesIOS10()
        }
    }
    
    @available(iOS 11.0, *)
    static func getFreeDiskSpaceInBytesIOS11() -> Int64 {
        let fileURL = URL(fileURLWithPath: Device.homeFolderString())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let availableCapacity = values.volumeAvailableCapacityForImportantUsage {
                return Int64(availableCapacity)
            }
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }
    
    static private func getFreeDiskSpaceInBytesIOS10() -> Int64 {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString())
            if let freeSize = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSize - 209715200 // 200MB - reserved system
            }
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }
    
    static func getTotalDiskSpace() -> Int64? {
        if #available(iOS 11.0, *) {
            return getTotalDiskSpaceIOS11()
        } else {
            return getTotalDiskSpaceIOS10()
        }
    }
    
    static func getTotalDiskSpaceIOS10() -> Int64? {
        do {
            let dict = try FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString())
            return (dict[.systemSize] as? NSNumber)?.int64Value
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    @available(iOS 11.0, *)
    static func getTotalDiskSpaceIOS11() -> Int64? {
        let fileURL = URL(fileURLWithPath: Device.homeFolderString())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            if let totalCapacity = values.volumeTotalCapacity {
                return Int64(totalCapacity)
            }
        } catch {
            print(error.localizedDescription)
        }
        return 0
    }
    
    static var getFreeDiskSpaceInPercent: Double {
        guard let totalSpace = getTotalDiskSpace() else {
            return 0
        }
        
        let freeSpace = getFreeDiskSpaceInBytes()
        
        return Double(freeSpace)/Double(totalSpace)
    }
    
    static var deviceInfo: [String: Any] {
        
        var result: [String: Any] = [:]
        let device = UIDevice.current
        
        if let uuid = device.identifierForVendor?.uuidString {
            result["uuid"] = uuid
        }
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            result["appVersion"] = appVersion
        }
        
        result["name"] = device.name
        result["deviceType"] = Device.deviceType
        result["language"] = Locale.current.languageCode ?? ""
        result["osVersion"] = Device.systemVersion

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
    
    static var workaroundUUID: String = { //Currently unused
        var UUID = ""
        if let storedUUID = UserDefaults.standard.object(forKey: Keys.fakeUUID) as? String {
            UUID = storedUUID
        } else {
            let newUUID = CFUUIDCreate(kCFAllocatorDefault)
            guard let tempoString = CFUUIDCreateString(kCFAllocatorDefault, newUUID) else {
                return UUID
            }
            UUID = String(tempoString).replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.set(UUID, forKey: Keys.fakeUUID)
        }
        return UUID
        
    }()
    
}
