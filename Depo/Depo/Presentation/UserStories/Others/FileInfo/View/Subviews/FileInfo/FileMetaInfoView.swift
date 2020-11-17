//
//  FileMetaInfoView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/11/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol FileMetaInfoViewProtocol: UIView {
    func reset()
    func setup(with wrapData: WrapData)
    func setup(with albumItem: AlbumItem)
    func set(createdDate: Date)
}

final class FileMetaInfoView: UIView, NibInit, FileMetaInfoViewProtocol {

    static func view() -> FileMetaInfoViewProtocol {
        let view = FileMetaInfoView.initFromNib()
        return view
    }
    
    @IBOutlet private weak var fileInfoLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoFileInfoTitle
            newValue.font = .TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var fileSizeTitleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var fileSizeLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }

    @IBOutlet private weak var durationStackView: UIStackView!
    
    @IBOutlet private weak var durationTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoDurationTitle
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var durationLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var uploadDateStackView: UIStackView!
    
    @IBOutlet private weak var uploadDateTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoUploadDateTitle
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var uploadDateLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }

    @IBOutlet private weak var takenDateStackView: UIStackView!
    
    @IBOutlet private weak var takenDateTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoTakenDateTitle
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var takenDateLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    private let formatter = ByteCountFormatter()
    
    //MARK: - Public

    func reset() {
        fileInfoLabel.text = TextConstants.fileInfoFileInfoTitle
        durationTitleLabel.text = TextConstants.fileInfoDurationTitle
        uploadDateTitleLabel.text = TextConstants.fileInfoUploadDateTitle
        takenDateTitleLabel.text = TextConstants.fileInfoTakenDateTitle
        
        durationStackView.isHidden = true
        uploadDateStackView.isHidden = true
        takenDateStackView.isHidden = true
    }
    
    func setup(with wrapData: WrapData) {
        if wrapData.fileType.typeWithDuration {
            durationLabel.text = wrapData.duration
            durationStackView.isHidden = false
        }
        
        formatter.countStyle = .binary
        fileSizeLabel.text = formatter.string(fromByteCount: wrapData.fileSize)
        
        if wrapData.fileType == .folder {
            fileInfoLabel.text = TextConstants.fileInfoFolderInfoTitle
            fileSizeTitleLabel.text = TextConstants.fileInfoAlbumSizeTitle
            fileSizeLabel.text = String(wrapData.childCount ?? 0)
            uploadDateTitleLabel.text = TextConstants.fileInfoCreationDateTitle
        } else {
            fileSizeTitleLabel.text = TextConstants.fileInfoFileSizeTitle
        }
        
        if let creationDate = wrapData.creationDate, !wrapData.isLocalItem {
            uploadDateLabel.text = creationDate.getDateInFormat(format: "dd MMMM yyyy")
            uploadDateStackView.isHidden = false
            
            if let takenDate = wrapData.metaData?.takenDate, creationDate != takenDate {
                takenDateLabel.text = takenDate.getDateInFormat(format: "dd MMMM yyyy")
                takenDateStackView.isHidden = false
            }
        }
    }
    
    func setup(with albumItem: AlbumItem) {
        uploadDateTitleLabel.text = TextConstants.fileInfoCreationDateTitle
        
        fileSizeTitleLabel.text = TextConstants.fileInfoAlbumSizeTitle
        fileInfoLabel.text = TextConstants.fileInfoAlbumInfoTitle
        
        var count = 0
        count += albumItem.audioCount ?? 0
        count += albumItem.imageCount ?? 0
        count += albumItem.videoCount ?? 0
        fileSizeLabel.text = String(count)
    }
    
    func set(createdDate: Date) {
        uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
        uploadDateStackView.isHidden = false
    }
}
