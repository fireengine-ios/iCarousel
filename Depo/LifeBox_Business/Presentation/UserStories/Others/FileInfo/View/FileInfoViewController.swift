//
//  FileInfoFileInfoViewController.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FileInfoViewController: BaseViewController, ActivityIndicator, ErrorPresenter {
    
    private var fileExtension: String?
    
    @IBOutlet weak var fileNameTitle: UILabel!
    @IBOutlet weak var fileName: UITextField!
    @IBOutlet weak var fileInfoTitle: UILabel!
    @IBOutlet weak var folderSizeTitle: UILabel!
    @IBOutlet weak var folderSizeLabel: UILabel!
    @IBOutlet weak var durationTitle: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationH: NSLayoutConstraint!
    @IBOutlet weak var moreFileInfoLabel: UILabel!
    @IBOutlet weak var uploadDateTitle: UILabel!
    @IBOutlet weak var uploadDateLabel: UILabel!
    @IBOutlet weak var takenDateTitle: UILabel!
    @IBOutlet weak var takenDateLabel: UILabel!
    
    @IBOutlet private weak var shareInfoContainer: UIView!
    private lazy var sharingInfoView = FileInfoShareView.with(delegate: self)
    
    private lazy var saveButton = UIBarButtonItem(title: TextConstants.fileInfoSave,
                                                  target: self,
                                                  selector: #selector(onSave))
    
    var output: FileInfoViewOutput!
    var interactor: FileInfoInteractor!
    private var fileType: FileType = .unknown
    
    private let sectionFont = UIFont.TurkcellSaturaBolFont(size: 14)
    private let sectionColor = ColorConstants.marineTwo
    private let infoFont = UIFont.TurkcellSaturaFont(size: 18)
    private let titleColor = UIColor.lrBrownishGrey
    private let infoColor = ColorConstants.closeIconButtonColor
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyleWithoutInsets()
    }
    
    private func setupUI() {
        let sectionTitles = [fileNameTitle, fileInfoTitle]
        sectionTitles.forEach {
            $0?.textColor = sectionColor
            $0?.font = sectionFont
        }
        
        let infoTitles = [folderSizeTitle, durationTitle, uploadDateTitle, takenDateTitle]
        infoTitles.forEach {
            $0?.textColor = titleColor
            $0?.font = infoFont
        }
        
        let infoFields = [folderSizeLabel, durationLabel, moreFileInfoLabel, uploadDateLabel, takenDateLabel]
        infoFields.forEach {
            $0?.textColor = infoColor
            $0?.font = infoFont
        }
        
        fileName.textColor = titleColor
        fileName.font = infoFont
        
        fileNameTitle.text = TextConstants.fileInfoFileNameTitle
        fileInfoTitle.text = TextConstants.fileInfoFileInfoTitle
        durationTitle.text = TextConstants.fileInfoDurationTitle
        uploadDateTitle.text = TextConstants.fileInfoUploadDateTitle
        takenDateTitle.text = TextConstants.fileInfoTakenDateTitle
    }

    private func addReturnIfNeed(string: inout String) {
        if !string.isEmpty {
            string.append("\n")
        }
    }
    
    private func configurateAudioMethadataFor(object: Item) {
        if let musickMethadata = object.metaData {
            var string = ""
            if let album = musickMethadata.album {
                string += TextConstants.fileInfoAlbumTitle + ": " + album
            }
            if let artist = musickMethadata.artist {
                addReturnIfNeed(string: &string)
                string += TextConstants.fileInfoArtistTitle + ": " + artist
            }
            if let title = musickMethadata.title {
                addReturnIfNeed(string: &string)
                string += TextConstants.fileInfoTitleTitle + ": " + title
            }
            
            moreFileInfoLabel.text = string
        }
    }
    
    private func checkCanEdit(item: BaseDataSourceItem, projectId: String?, permission: SharedItemPermission?) {
        var canEdit = true
        if projectId != SingletonStorage.shared.accountInfo?.projectID {
            canEdit = permission?.granted?.contains(.setAttribute) == true
        }
        
        if item.isLocalItem || item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum {
            canEdit = false
        }
        
        navigationItem.rightBarButtonItem = canEdit ? saveButton : nil
        fileName.isEnabled = canEdit
    }
    
    private func hideInfoDateLabels () {
        takenDateLabel.isHidden = true
        takenDateTitle.isHidden = true
        uploadDateLabel.isHidden = true
        uploadDateTitle.isHidden = true
    }
    
    // MARK: Actions
    
    @IBAction func onHideKeyboard() {
        if let text = fileName.text {
            output.validateName(newName: text)
        }
    }
    
    @objc func onSave() {
        
        guard let text = fileName.text?.nonEmptyString else {
            return
        }
        if let fileExtension = fileExtension?.nonEmptyString {
            output.onRename(newName: text.makeFileName(with: fileExtension))
        } else if fileType == .folder || fileType == .photoAlbum {
            output.onRename(newName: text)
        }
    }
    
}

// MARK: FileInfoViewInput

extension FileInfoViewController: FileInfoViewInput {
    
    func startRenaming() {
        if fileName == nil {
            _ = view
        }
        fileName.becomeFirstResponder()
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setObject(_ object: BaseDataSourceItem) {
        
        fileName.text = object.name
        fileType = object.fileType
        
        if let obj = object as? WrapData {
            if obj.fileType == .audio {
                configurateAudioMethadataFor(object: obj)
            }
            
            if obj.fileType.typeWithDuration {
                durationLabel.text = obj.duration
            } else {
                durationH.constant = 0
                view.layoutSubviews()
            }
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            folderSizeLabel.text = formatter.string(fromByteCount: obj.fileSize)
            
            if obj.fileType == .folder {
                fileNameTitle.text = TextConstants.fileInfoFolderNameTitle
                fileInfoTitle.text = TextConstants.fileInfoFolderInfoTitle
                folderSizeTitle.text = TextConstants.fileInfoAlbumSizeTitle
                folderSizeLabel.text = String(obj.childCount ?? 0)
                uploadDateTitle.text = TextConstants.fileInfoCreationDateTitle
            } else {
                folderSizeTitle.text = TextConstants.fileInfoFileSizeTitle
            }
            
            if let createdDate = obj.creationDate, !object.isLocalItem {
                uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
                if !obj.isLocalItem, let takenDate = obj.metaData?.takenDate, createdDate != takenDate {
                    takenDateLabel.text = takenDate.getDateInFormat(format: "dd MMMM yyyy")
                } else {
                    takenDateLabel.isHidden = true
                    takenDateTitle.isHidden = true
                }
            } else {
                hideInfoDateLabels()
            }
            checkCanEdit(item: object, projectId: object.projectId, permission: nil)
            return
        }
        
        if let album = object as? AlbumItem {
            uploadDateTitle.text = TextConstants.fileInfoCreationDateTitle
            folderSizeTitle.text = TextConstants.fileInfoAlbumSizeTitle
            fileNameTitle.text = TextConstants.fileInfoAlbumNameTitle
            fileInfoTitle.text = TextConstants.fileInfoAlbumInfoTitle
            var count = 0
            count += album.audioCount ?? 0
            count += album.imageCount ?? 0
            count += album.videoCount ?? 0
            folderSizeLabel.text = String(count)
            
            if album.readOnly == true {
                fileName.isEnabled = false
            }
        }
        
        if let createdDate = object.creationDate {
            uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
            takenDateLabel.isHidden = true
            takenDateTitle.isHidden = true
        } else {
            hideInfoDateLabels()
        }
        
        checkCanEdit(item: object, projectId: object.projectId, permission: nil)
        
        durationH.constant = 0
        view.layoutIfNeeded()
    }
    
    func show(name: String) {
        fileExtension = (name as NSString).pathExtension
        
        if fileName.isFirstResponder {
            fileName.text = (name as NSString).deletingPathExtension
        } else {
            fileName.text = name
        }
    }
    
    func showValidateNameSuccess() {
        fileName.resignFirstResponder()
        
        guard
            let text = fileName.text?.nonEmptyString,
            let fileExtension = fileExtension?.nonEmptyString
        else {
            return
        }
        fileName.text = text.makeFileName(with: fileExtension)
    }
    
    func hideViews() {
        view.subviews.forEach { $0.isHidden = true }
    }
    
    func showViews() {
        view.subviews.forEach { $0.isHidden = false }
    }
    
    func showSharingInfo(_ sharingInfo: SharedFileInfo) {
        if sharingInfo.members == nil || sharingInfo.members?.isEmpty == true {
            sharingInfoView.isHidden = true
        } else if sharingInfoView.superview == nil {
            shareInfoContainer.addSubview(sharingInfoView)
            sharingInfoView.translatesAutoresizingMaskIntoConstraints = false
            sharingInfoView.pinToSuperviewEdges()
        }
        
        sharingInfoView.setup(with: sharingInfo)
        
        if let item = interactor.item {
            checkCanEdit(item: item, projectId: sharingInfo.projectId, permission: sharingInfo.permissions)
        }
    }
    
    func deleteSharingInfo() {
        sharingInfoView.removeFromSuperview()
    }
}

// MARK: UITextFieldDelegate

extension FileInfoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text {
            output.onRename(newName: text)
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            textField.text = (text as NSString).deletingPathExtension
            if fileExtension == nil {
                fileExtension = (text as NSString).pathExtension
            }
        }
        
        return true
    }
    
}

//MARK: - FileInfoShareViewDelegate

extension FileInfoViewController: FileInfoShareViewDelegate {
    
    func didSelect(contact: SharedContact) {
        output.openShareAccessList(contact: contact)
    }
    
    func didTappedPlusButton() {
        output.shareItem()
    }
    
    func didTappedArrowButton() {
        if let info = sharingInfoView.info {
            output.showWhoHasAccess(shareInfo: info)
        }
    }
}
