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
    
    @IBOutlet private weak var fileLabel: UILabel! {
        willSet {
            newValue.font = .GTAmericaStandardRegularFont(size: 14)
            newValue.textColor = ColorConstants.textGrayColor.color
        }
    }
    
    @IBOutlet private weak var thumbnailImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    private var fileType: FileType = .unknown
    
    private var cellImageManager: CellImageManager?
    private var uuid: String?

    //MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageManager?.cancelImageLoading()
        thumbnailImageView.image = nil
        fileBGImage.image = nil
        fileImage.image = nil
        uuid = nil
    }
    
    func setup(item: Item) {
        self.fileType = item.fileType
        fileLabel.text = item.name
        
        setImage(fileType: fileType)
        
        if case PathForItem.remoteUrl(let url) = item.patchToPreview, let imageUrl = url {
            loadImage(with: item, url: imageUrl)
        }
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
    
    private func loadImage(with item: Item, url: URL) {
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                
                guard let image = image, self.uuid == uniqueId else {
                    self.setImage(fileType: self.fileType)
                    return
                }
                
                self.thumbnailImageView.image = image
            }
        }
        
        cellImageManager?.loadImage(item: item, thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
    }
}
