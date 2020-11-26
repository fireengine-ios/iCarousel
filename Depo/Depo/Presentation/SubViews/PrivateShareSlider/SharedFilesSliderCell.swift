//
//  SharedFilesSliderCell.swift
//  Depo
//
//  Created by Alex Developer on 23.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

final class SharedFilesSliderCell: UICollectionViewCell {
    
    @IBOutlet private weak var fileBGImage: UIImageView!
    
    @IBOutlet private weak var fileImage: UIImageView!
    
    @IBOutlet private weak var fileLabel: UILabel!
    
    private var fileType: FileType = .unknown
    private var text: String? {
        didSet {
            fileLabel.text = text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(text: String, fileType: FileType) {
        self.fileType = fileType
        self.text = text
        
        setImage(fileType: fileType)
    }
    
    private func setImage(fileType: FileType) {
        switch fileType {
        case .folder:
            fileBGImage.image = UIImage(named: "AF_PS_folder_Border")
            fileImage.image = UIImage(named: "AF_PS_folder")
        case .image:
            fileBGImage.image = UIImage(named: "AF_PS_photo_Border")
            fileImage.image = UIImage(named: "AF_PS_photo")
        case .video:
            fileBGImage.image = UIImage(named: "AF_PS_video_Border")
            fileImage.image = UIImage(named: "AF_PS_video")
        case .audio:
            fileBGImage.image = UIImage(named: "AF_PS_audio_Border")
            fileImage.image = UIImage(named: "AF_PS_audio")
        case .application(let subType):
            switch subType {
            case .doc:
                fileBGImage.image = UIImage(named: "AF_PS_DOC_Border")
                fileImage.image = UIImage(named: "AF_PS_DOC")
            case .pdf:
                fileBGImage.image = UIImage(named: "AF_PS_PDF_Border")
                fileImage.image = UIImage(named: "AF_PS_PDF")
            case .ppt, .pptx:
                fileBGImage.image = UIImage(named: "AF_PS_PPT_Border")
                fileImage.image = UIImage(named: "AF_PS_PPT")
            case .xls:
                fileBGImage.image = UIImage(named: "AF_PS_XLS_Border")
                fileImage.image = UIImage(named: "AF_PS_XLS")
            case .zip:
                fileBGImage.image = UIImage(named: "AF_PS_ZIP_Border")
                fileImage.image = UIImage(named: "AF_PS_ZIP")
            default:
                //unknown
                fileBGImage.image = UIImage(named: "AF_PS_Unknown_Border")
                fileImage.image = UIImage(named: "AF_PS_Unknown")
            }
        default:
            //unknown
            fileBGImage.image = UIImage(named: "AF_PS_Unknown_Border")
            fileImage.image = UIImage(named: "AF_PS_Unknown")
        }
    }
    
}
