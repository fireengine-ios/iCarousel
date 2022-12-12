//
//  ActivityFileType.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum ActivityFileType: String {
    case image = "IMAGE"
    case video = "VIDEO"
    case document = "DOCUMENT"
    case audio = "AUDIO"
    case directory = "DIRECTORY"
    case other = "OTHER"
    case album = "album"
    case text = "text"
    case text2 = "text/plain"
    
    case rar = "octet-stream"
    case rarx = "application/x-rar-compressed"
    case document2 = "application/vnd.openxmlformats-officedocument" // ???
    case pdf = "application/pdf"
    case doc = "application/msword"
    case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case xls = "application/vnd.ms-excel"
    case xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case ppt = "application/vnd.ms-powerpoint"
    case pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case dir = "application/directory"
    case zip = "application/zip"
    
}
extension ActivityFileType {
    var image: UIImage {
        switch self {
        case .image:
            return #imageLiteral(resourceName: "fileIconPhoto")
        case .video:
            return #imageLiteral(resourceName: "fileIconVideo")
        case .document:
            return #imageLiteral(resourceName: "fileIconUnknown")
        case .audio:
            return #imageLiteral(resourceName: "fileIconAudio")
        case .directory:
            return Image.iconFolder.image
        case .other:
            return #imageLiteral(resourceName: "fileIconUnknown")
        case .album:
            return #imageLiteral(resourceName: "fileIconPhoto")
        case .text:
            return #imageLiteral(resourceName: "fileIconTxt")
        case .text2:
            return #imageLiteral(resourceName: "fileIconTxt")
            
        case .rar:
            return #imageLiteral(resourceName: "fileIconRar")
        case .rarx:
            return #imageLiteral(resourceName: "fileIconRar")
        case .document2:
            return #imageLiteral(resourceName: "fileIconTxt")
        case .pdf:
            return #imageLiteral(resourceName: "fileIconPdf")
        case .doc:
            return #imageLiteral(resourceName: "fileIconDoc")
        case .docx:
            return #imageLiteral(resourceName: "fileIconDoc")
        case .xls:
            return #imageLiteral(resourceName: "fileIconXls")
        case .xlsx:
            return #imageLiteral(resourceName: "fileIconXls")
        case .ppt:
            return #imageLiteral(resourceName: "fileIconPpt")
        case .pptx:
            return #imageLiteral(resourceName: "fileIconPpt")
        case .dir:
            return Image.iconFolder.image
        case .zip:
            return #imageLiteral(resourceName: "fileIconZip")
        }
    }
}
