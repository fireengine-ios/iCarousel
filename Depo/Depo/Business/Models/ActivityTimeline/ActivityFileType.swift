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
            return Image.iconFilePhoto.image
        case .video:
            return Image.iconFileVideo.image
        case .document:
            return Image.iconFileEmpty.image
        case .audio:
            return Image.iconFileAudio.image
        case .directory:
            return Image.iconFolder.image
        case .other:
            return Image.iconFileEmpty.image
        case .album:
            return Image.iconFilePhoto.image
        case .text:
            return Image.iconFileTxt.image
        case .text2:
            return Image.iconFileTxt.image
            
        case .rar:
            return Image.iconFileRar.image
        case .rarx:
            return Image.iconFileRar.image
        case .document2:
            return Image.iconFileTxt.image
        case .pdf:
            return Image.iconFilePdf.image
        case .doc:
            return Image.iconFileDoc.image
        case .docx:
            return Image.iconFileDoc.image
        case .xls:
            return Image.iconFileXls.image
        case .xlsx:
            return Image.iconFileXls.image
        case .ppt:
            return Image.iconFilePpt.image
        case .pptx:
            return Image.iconFilePpt.image
        case .dir:
            return Image.iconFolder.image
        case .zip:
            return Image.iconFileZip.image
        }
    }
}
