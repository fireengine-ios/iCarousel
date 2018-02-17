//
//  ImageFormat.swift
//  Images
//
//  Created by Bondar Yaroslav on 2/17/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import Foundation

/// can be done "heic", "heix", "hevc", "hevx"
/// + WEBP
enum ImageFormat: String {
    case png, jpg, gif, tiff, heic, unknown
}

extension ImageFormat {
    static func get(from data: Data) -> ImageFormat {
        
        var headerData: UInt8 = 0
        data.copyBytes(to: &headerData, count: 1)
        
        switch headerData {
        case 0x89:
            return .png
        case 0xFF:
            return .jpg
        case 0x47:
            return .gif 
        case 0x49, 0x4D:
            return .tiff 
            
            //        case 0x52: {
            //            if (data.length >= 12) {
            //                //RIFF....WEBP
            //                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            //                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
            //                    return SDImageFormatWebP;
            //                }
            //            }
            //            break;
            //            }
            
        case 0x00:
            
            guard data.count >= 12 else {
                return .unknown
            }
            
            let startIndex = data.index(data.startIndex, offsetBy: 8) ///4
            let endIndex = data.index(data.startIndex, offsetBy: 11)
            let subdata = data[startIndex...endIndex]
            
            if let str = String(data: subdata, encoding: .ascii),
                Set(["heic", "heix", "hevc", "hevx"]).contains(str) ///"ftypheic", "ftypheix", "ftyphevc", "ftyphevx"
            {    
                return .heic
            }
            
            return .unknown
        default:
            return .unknown
        }
    } 
    
    var contentType: String {
        return "image/\(rawValue)"
    }
}
