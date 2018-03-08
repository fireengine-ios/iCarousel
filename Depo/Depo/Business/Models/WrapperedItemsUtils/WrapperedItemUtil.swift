//
//  WrapperedItemUtil.swift
//  Depo
//
//  Created by Oleg on 22.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class WrapperedItemUtil: NSObject {
    
    class func getSmallPreviewImageForWrapperedObject(fileType: FileType) -> UIImage? {
        var imageName = "fileIconUnknown"
        
        switch fileType {
        case .image:
            imageName = "fileIconPhoto"
            
        case .video:
            imageName = "fileIconVideo"
            
        case .audio:
            imageName = "fileIconAudio"
            
        case .folder:
            imageName = "fileIconFolder"
            
        case .photoAlbum: // TODO: Add icon
            imageName = "fileIconUnknown"
            
        case .musicPlayList: // TODO: Add icon
            imageName = "fileIconUnknown"
            
        case let .application(applicationType):
            switch applicationType {
            case .rar:
                imageName = "fileIconRar"
                break
            case .zip:
                imageName = "fileIconZip"
                break
            case .doc:
                imageName = "fileIconDoc"
                break
            case .txt:
                imageName = "fileIconTxt"
                break
            case .html:
                imageName = "fileIconUnknown"
                break
            case .xls:
                imageName = "fileIconXls"
                break
            case .pdf:
                imageName = "fileIconPdf"
                break
            case .ppt:
                imageName = "fileIconPpt"
                break
            default:
                break
            }
        default:
            imageName = "fileIconUnknown"
        }
        return UIImage(named: imageName)
    }
    
    class func getPreviewImageForWrapperedObject(fileType: FileType) -> UIImage? {
        var imageName = "fileBigIconUnknown"
        switch fileType {
        case .image:
            imageName = "fileBigIconPhoto"
            
        case .video:
            imageName = "fileBigIconVideo"
            
        case .audio:
            imageName = "fileBigIconAudio"
            
        case .folder:
            imageName = "fileBigIconFolder"
            
        case .photoAlbum: // TODO: Add icon
            imageName = "fileIconUnknown"
            
        case .musicPlayList: // TODO: Add icon
            imageName = "fileIconUnknown"
        case let .application(applicationType):
            switch applicationType {
            case .rar:
                imageName = "fileBigIconAchive"
                break
            case .zip:
                imageName = "fileBigIconAchive"
                break
            case .doc:
                imageName = "fileBigIconDoc"
                break
            case .txt:
                imageName = "fileBigIconTxt"
                break
            case .html:
                imageName = "fileIconUnknown"
                break
            case .xls:
                imageName = "fileBigIconXls"
                break
            case .pdf:
                imageName = "fileBigIconPdf"
                break
            case .ppt:
                imageName = "fileBigIconPpt"
                break
            default:
                break
            }
            
        default:
            imageName = "fileIconUnknown"
            break
        }
        return UIImage(named: imageName)
    }
    
    class func getSmallPreviewImageForNotSelectedWrapperedObject(fileType: FileType) -> UIImage? {
        var imageName = "fileIconSmallUnknownNotSelected"
        switch fileType {
        case .image:
            imageName = "fileIconSmallPhotoNotSelected"
            
        case .video:
            imageName = "fileIconSmallVideoNotSelected"
            
        case .audio:
            imageName = "fileIconSmallAudioNotSelected"
            
        case .folder:
            imageName = "fileIconSmallFolderNotSelected"
        
        case .photoAlbum: // TODO: Add icon
            imageName = "fileIconUnknown"
            
        case .musicPlayList: // TODO: Add icon
            imageName = "fileIconUnknown"
        case let .application(applicationType):
            switch applicationType {
            case .rar:
                imageName = "fileIconSmallRarNotSelected"
                break
            case .zip:
                imageName = "fileIconSmallZipNotSelected"
                break
            case .doc:
                imageName = "fileIconSmallDocNotSelected"
                break
            case .txt:
                imageName = "fileIconSmallTxtNotSelected"
                break
            case .html:
                imageName = "fileIconSmallUnknownNotSelected"
                break
            case .xls:
                imageName = "fileIconSmallXlsNotSelected"
                break
            case .pdf:
                imageName = "fileIconSmallPdfNotSelected"
                break
            case .ppt:
                imageName = "fileIconSmallPptNotSelected"
                break
            default:
                break
            }
            default:
                break
        }
        return UIImage(named: imageName)
    }
    
}
