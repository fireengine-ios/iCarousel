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
        
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    func setObject(object: BaseDataSourceItem){
        
        fileName.text = object.name
        
        if (object.fileType == FileType.folder){
            folderSizeTitle.text = TextConstants.fileInfoFolderSizeTitle
        }else{
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
            
        } else {
            durationH.constant = 0
            view.layoutSubviews()
        }
        
        dateModifiedLabel.text = object.creationDate?.getDateInFormat(format: "dd MMMM yyyy")
    }
    
    func addReturnIfNeed(string: inout String){
        if (string.characters.count > 0){
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
    func setupInitialState() {
        
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        output.onRename(newName: textField.text!)
        return true
    }
    
    // MARK: Button actions
    
    @IBAction func onHideKeyboard(){
        fileName.resignFirstResponder()
    }
}
