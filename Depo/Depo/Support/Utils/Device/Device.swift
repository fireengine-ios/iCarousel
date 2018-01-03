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
    
    static var isIpad:Bool {
        return UI_USER_INTERFACE_IDIOM() == .pad
    }
    
    static var getFreeDiskspace: UInt64 {
        var totalFreeSpace: UInt64 = 0
        
        do {
           let dict = try FileManager.default.attributesOfFileSystem(forPath: Device.homeFolderString())
            
            totalFreeSpace = (dict[.systemFreeSize] as! NSNumber).uint64Value
            
        } catch {
            print("Can't calculate file size")
        }
         return totalFreeSpace
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
    
    static var deviceInfo:[String:Any] {
        
        var result : [String:Any] = [:]
        let device =  UIDevice.current
        
        if let uuid = device.identifierForVendor?.uuidString {
            result["uuid"] = uuid
        }
        result["name"] = device.name
        result["deviceType"] = isIpad ? "IPAD":"IPHONE"
        return result
    }
    
    static var locale: String {
       return Locale.current.languageCode ?? "en"
    }
    
    static var winSize = UIScreen.main.bounds
}
