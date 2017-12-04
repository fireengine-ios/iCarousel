//
//  FileInfoFileInfoViewController.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FileInfoViewController: UIViewController, FileInfoViewInput, UITextFieldDelegate {
    
    @IBOutlet weak var fileNameTitle: UILabel!
    @IBOutlet weak var fileName: UITextField!
    @IBOutlet weak var fileInfoTitle: UILabel!
    @IBOutlet weak var folderSizeTitle: UILabel!
    @IBOutlet weak var folderSizeLabel: UILabel!
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationH: NSLayoutConstraint!
    @IBOutlet weak var moreFileInfoLabel: UILabel!
    @IBOutlet weak var dateModifiedTitle: UILabel!
    @IBOutlet weak var dateModifiedLabel: UILabel!
    @IBOutlet weak var uploadDateTitle: UILabel!
    @IBOutlet weak var uploadDateLabel: UILabel!
    @IBOutlet weak var takenDateTitle: UILabel!
    @IBOutlet weak var takenDateLabel: UILabel!
    
    var output: FileInfoViewOutput!
    var interactor: FileInfoInteractor!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        fileNameTitle.text = TextConstants.fileInfoFileNameTitle
        fileNameTitle.textColor = ColorConstants.blueColor
        fileNameTitle.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        fileName.textColor = ColorConstants.textGrayColor
        fileName.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        fileInfoTitle.text = TextConstants.fileInfoInfoTitle
        fileInfoTitle.textColor = ColorConstants.blueColor
        fileInfoTitle.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        folderSizeTitle.textColor = ColorConstants.textGrayColor
        folderSizeTitle.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        folderSizeLabel.textColor = ColorConstants.textGrayColor
        folderSizeLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        durationTitle.text = TextConstants.fileInfoDurationTitle
        durationTitle.textColor = ColorConstants.textGrayColor
        durationTitle.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        durationLabel.textColor = ColorConstants.textGrayColor
        durationLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        dateModifiedTitle.text = TextConstants.fileInfoDateModifiedTitle
        dateModifiedTitle.textColor = ColorConstants.textGrayColor
        dateModifiedTitle.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        dateModifiedLabel.textColor = ColorConstants.textGrayColor
        dateModifiedLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        moreFileInfoLabel.textColor = ColorConstants.textGrayColor
        moreFileInfoLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        uploadDateTitle.text = TextConstants.fileInfoUploadDateTitle
        uploadDateTitle.textColor = ColorConstants.textGrayColor
        uploadDateTitle.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        uploadDateLabel.textColor = ColorConstants.textGrayColor
        uploadDateLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        
        takenDateTitle.text = TextConstants.fileInfoTakenDateTitle
        takenDateTitle.textColor = ColorConstants.textGrayColor
        takenDateTitle.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        takenDateLabel.textColor = ColorConstants.textGrayColor
        takenDateLabel.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        let saveButton = UIBarButtonItem(title: TextConstants.fileInfoSave, style: .done, target: self, action: #selector(onSave))
        
        navigationItem.setRightBarButton(saveButton, animated: false)
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    func setObject(object: BaseDataSourceItem){
        
        fileName.text = object.name
        
        if (object.fileType == .folder){
            folderSizeTitle.text = TextConstants.fileInfoFolderSizeTitle
        } else if object.fileType == .photoAlbum {
            
        }  else {
            folderSizeTitle.text = TextConstants.fileInfoFileSizeTitle
        }
        
        if let obj = object as? WrapData {
             if obj.fileType == .audio {
                configurateAudioMethadataFor(object: obj)
            }
            
            if (obj.fileType.typeWithDuration){
                durationLabel.text = obj.duration
            } else {
                durationH.constant = 0
                view.layoutSubviews()
            }

            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            folderSizeLabel.text = formatter.string(fromByteCount: obj.fileSize)
        } else if let album = object as? AlbumItem {
            folderSizeTitle.text = TextConstants.fileInfoAlbumSizeTitle
            fileNameTitle.text = TextConstants.fileInfoAlbumNameTitle
            fileInfoTitle.text = TextConstants.fileInfoAlbumInfoTitle
            var count = 0
            count += album.audioCount ?? 0
            count += album.imageCount ?? 0
            count += album.videoCount ?? 0
            folderSizeLabel.text = String(count)
            durationH.constant = 0
        } else {
            durationH.constant = 0
            view.layoutSubviews()
        }
        
        dateModifiedLabel.text = object.lastModifiDate?.getDateInFormat(format: "dd MMMM yyyy")
        
        if let obj = object as? WrapData, obj.syncStatus == .synced, let takenDate = obj.metaData?.takenDate {
            takenDateLabel.text = takenDate.getDateInFormat(format: "dd MMMM yyyy")
            if let createdDate = object.creationDate, createdDate == takenDate {
                uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
            } else {
                uploadDateLabel.isHidden = true
                uploadDateTitle.isHidden = true
            }
        } else {
            takenDateLabel.isHidden = true
            takenDateTitle.isHidden = true
            uploadDateLabel.isHidden = true
            uploadDateTitle.isHidden = true
        }
    }
    
    func addReturnIfNeed(string: inout String){
        if string.count > 0 {
            string.append("\n")
        }
    }
    
    func configurateAudioMethadataFor(object: Item){
        if let musickMethadata = object.metaData {
            var string = ""
            if let album = musickMethadata.album {
                string.append(TextConstants.fileInfoAlbumTitle)
                string.append(": ")
                string.append(album)
            }
            if let artist = musickMethadata.artist {
                addReturnIfNeed(string: &string)
                string.append(TextConstants.fileInfoArtistTitle)
                string.append(": ")
                string.append(artist)
            }
            if let title = musickMethadata.title {
                addReturnIfNeed(string: &string)
                string.append(TextConstants.fileInfoTitleTitle)
                string.append(": ")
                string.append(title)
            }
            
            moreFileInfoLabel.text = string
        }
    }


    // MARK: FileInfoViewInput
    
    func startRenaming() {
        if fileName == nil {
            let _ = view
        }
        fileName.becomeFirstResponder()
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        output.onRename(newName: textField.text!)
        return true
    }
    
    
    // MARK: Actions
    
    @IBAction func onHideKeyboard(){
        fileName.resignFirstResponder()
    }
    
    @objc func onSave() {
        output.onRename(newName: fileName.text!)
    }
    
}
