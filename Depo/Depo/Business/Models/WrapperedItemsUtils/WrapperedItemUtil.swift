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
        var image = Image.iconFileEmpty
        
        switch fileType {
        case .image:
            image = Image.iconFilePhoto
            
        case .video:
            image = Image.iconFileVideo
            
        case .audio:
            image = Image.iconMusic
            
        case .folder:
            if #available(iOS 13.0, *) {
                return Image.iconFolder.image.withTintColor(AppColor.filesLabel.color, renderingMode: .automatic)
            } else {
                return Image.iconFolder.image
            }
            
        case .photoAlbum, .faceImageAlbum(_):
            image = Image.iconFilePhoto
            
        case .musicPlayList: // TODO: Add icon
            image = Image.iconFileEmpty
            
        case let .application(applicationType):
            switch applicationType {
            case .rar:
                image = Image.iconFileRar
                break
            case .zip:
                image = Image.iconFileZip
                break
            case .doc:
                image = Image.iconFileDoc
                break
            case .txt:
                image = Image.iconFileTxt
                break
            case .html:
                image = Image.iconFileEmpty
                break
            case .xls:
                image = Image.iconFileXls
                break
            case .pdf:
                image = Image.iconFilePdf
                break
            case .ppt, .pptx:
                image = Image.iconFilePpt
                break
            default:
                break
            }
        default:
            image = Image.iconFileEmpty
        }
        return image.image
    }
    
    class func getBigPreviewImageForWrapperedObject(fileType: FileType) -> UIImage? {
        var image = Image.iconFileEmptyBig
        
        switch fileType {
        case .image:
            image = Image.iconFilePhotoBig
            
        case .video:
            image = Image.iconFileVideoBig
            
        case .audio:
            image = Image.iconMusicBig
            
        case .folder:
            if #available(iOS 13.0, *) {
                return Image.iconFolderBig.image.withTintColor(AppColor.filesLabel.color, renderingMode: .automatic)
            } else {
                return Image.iconFolderBig.image
            }

        case .photoAlbum, .faceImageAlbum(_):
            image = Image.iconFilePhotoBig
            
        case .musicPlayList: // TODO: Add icon
            image = Image.iconFileEmptyBig
            
        case let .application(applicationType):
            switch applicationType {
            case .rar:
                image = Image.iconFileRarBig
                break
            case .zip:
                image = Image.iconFileZipBig
                break
            case .doc:
                image = Image.iconFileDocBig
                break
            case .txt:
                image = Image.iconFileTxtBig
                break
            case .html:
                image = Image.iconFileEmptyBig
                break
            case .xls:
                image = Image.iconFileXlsBig
                break
            case .pdf:
                image = Image.iconFilePdfBig
                break
            case .ppt, .pptx:
                image = Image.iconFilePptBig
                break
            default:
                break
            }
        default:
            image = Image.iconFileEmptyBig
        }
        return image.image
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
        
        case .photoAlbum, .faceImageAlbum(_): // TODO: Add icon
            imageName = "fileIconSmallPhotoNotSelected"
            
        case .musicPlayList: // TODO: Add icon
            imageName = "iconFileEmpty"
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
            case .ppt, .pptx:
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
    
    static func privateSharePlaceholderImage(fileType: FileType) -> UIImage? {
        switch fileType {
        case .folder:
            return UIImage(named: "AF_PS_folder")
        case .image:
            return UIImage(named: "AF_PS_photo")
        case .video:
            return UIImage(named: "AF_PS_video")
        case .audio:
            return UIImage(named: "AF_PS_audio")
        case .application(let subType):
            switch subType {
            case .doc:
                return UIImage(named: "AF_PS_DOC")
            case .pdf:
                return UIImage(named: "AF_PS_PDF")
            case .ppt, .pptx:
                return UIImage(named: "AF_PS_PPT")
            case .xls:
                return UIImage(named: "AF_PS_XLS")
            case .zip:
                return UIImage(named: "AF_PS_ZIP")
            default:
                //unknown
                return UIImage(named: "AF_PS_Unknown")
            }
        default:
            //unknown
            return UIImage(named: "AF_PS_Unknown")
        }
    }
    
}
