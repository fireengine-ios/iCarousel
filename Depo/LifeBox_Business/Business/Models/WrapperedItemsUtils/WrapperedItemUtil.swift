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
        var imageName = "unknownFileThumbnail"
        
        switch fileType {
        case .image:
            imageName = "photoFileThumbnail"
            
        case .video:
            imageName = "videoFileThumbnail"
            
        case .audio:
            imageName = "audioFileThumbnail"
            
        case .folder:
            imageName = "folderFileThumbnail"
            
        case .musicPlayList: // TODO: Add icon
            imageName = "unknownFileThumbnail"
            
        case let .application(applicationType):
            switch applicationType {
            case .rar:
                imageName = "fileIconRar"
                break
            case .zip:
                imageName = "zipFileThumbnail"
                break
            case .doc:
                imageName = "docFileThumbnail"
                break
            case .txt:
                imageName = "txtFileThumbnail"
                break
            case .html:
                imageName = "fileIconUnknown"
                break
            case .xls:
                imageName = "xlsFileThumbnail"
                break
            case .pdf:
                imageName = "pdfFileThumbnail"
                break
            case .ppt, .pptx:
                imageName = "pptFileThumbnail"
                break
            default:
                break
            }
        default:
            imageName = "unknownFileThumbnail"
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
            
        case .musicPlayList: // TODO: Add icon
            imageName = "fileBigIconUnknown"
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
                imageName = "fileBigIconUnknown"
                break
            case .xls:
                imageName = "fileBigIconXls"
                break
            case .pdf:
                imageName = "fileBigIconPdf"
                break
            case .ppt, .pptx:
                imageName = "fileBigIconPpt"
                break
            default:
                break
            }
            
        default:
            imageName = "fileBigIconUnknown"
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
            return UIImage(named: "folderFileThumbnail")
        case .image:
            return UIImage(named: "photoFileThumbnail")
        case .video:
            return UIImage(named: "videoFileThumbnail")
        case .audio:
            return UIImage(named: "audioFileThumbnail")
        case .application(let subType):
            switch subType {
            case .doc:
                return UIImage(named: "docFileThumbnail")
            case .pdf:
                return UIImage(named: "pdfFileThumbnail")
            case .ppt, .pptx:
                return UIImage(named: "pptFileThumbnail")
            case .xls:
                return UIImage(named: "xlsFileThumbnail")
            case .zip:
                return UIImage(named: "zipFileThumbnail")
            default:
                //unknown
                return UIImage(named: "unknownFileThumbnail")
            }
        default:
            //unknown
            return UIImage(named: "unknownFileThumbnail")
        }
    }
    
    static func previewPlaceholderImage(fileType: FileType) -> UIImage? {
        switch fileType {
            case .image:
                return UIImage(named: "photoLoading")
            case .video:
                return UIImage(named: "videoLoading")
            case .audio:
                return UIImage(named: "audioLoading")
            case .application(let subType):
                switch subType {
                    case .txt:
                        return UIImage(named: "txtLoading")
                    case .doc:
                        return UIImage(named: "docLoading")
                    case .pdf:
                        return UIImage(named: "pdfLoading")
                    case .ppt, .pptx:
                        return UIImage(named: "pptLoading")
                    case .csv:
                        return UIImage(named: "csvLoading")
                    case .xls:
                        return UIImage(named: "xlsLoading")
                    case .zip:
                        return UIImage(named: "zipLoading")
                    default:
                        //unknown
                        return UIImage(named: "unknownLoading")
                }
            default:
                //unknown
                return UIImage(named: "unknownLoading")
        }
    }
    
}
