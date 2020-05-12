//
//  PhotoInfoViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros12 on 5/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoInfoViewControllerOutput {
    func onRename(newName: String)
    func validateName(newName: String)
}

class PhotoInfoViewController: UIView {
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var backgroundView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 7
        }
    }
    
    @IBOutlet weak var fileNameTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoFileNameTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet weak var fileNameStackView: UIStackView!
    @IBOutlet weak var fileNameField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var editIconImageView: UIImageView!
    @IBOutlet private weak var applyIconImageView: UIImageView!
    @IBOutlet private weak var cancelIconImageView: UIImageView!
    
    @IBOutlet private weak var fileInfoLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoFileInfoTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var fileSizeTitleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var fileSizeLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet weak var durationStackView: UIStackView!
    
    @IBOutlet weak var durationTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoDurationTitle
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet weak var durationLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var uploadDateStackView: UIStackView!
    
    @IBOutlet private weak var uploadDateTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoUploadDateTitle
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var uploadDateLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var takenDateStackView: UIStackView!
    
    @IBOutlet private weak var takenDateTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoTakenDateTitle
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var takenDateLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var peopleTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.myStreamPeopleTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var enableStackView: UIStackView!
    @IBOutlet private weak var enableTextLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoPeople
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var enableButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitleColor(.white, for: UIControl.State())
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = ColorConstants.marineTwo
            newValue.setTitle(TextConstants.passcodeEnable, for: UIControl.State())
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var peopleCollectionView: UICollectionView!
    
    private var fileExtension: String?
    private var oldName: String?
    private var isEditing = true
    var output: PhotoInfoViewControllerOutput!
        
    // MARK: Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setup()
    }
    
    private func addReturnIfNeed(string: inout String) {
        if !string.isEmpty {
            string.append("\n")
        }
    }
    
    private func setupView() {
        let nibNamed = String(describing: PhotoInfoViewController.self)
        Bundle(for: PhotoInfoViewController.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setup() {
        fileNameField.delegate = self
        fileNameField.isUserInteractionEnabled = false
        let editGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onEdit(tapGestureRecognizer:)))
        editIconImageView.isUserInteractionEnabled = true
        editIconImageView.addGestureRecognizer(editGestureRecognizer)
        
        let applyGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSave))
        applyIconImageView.isUserInteractionEnabled = true
        applyIconImageView.addGestureRecognizer(applyGestureRecognizer)
        
        let cancelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCancel))
        cancelIconImageView.isUserInteractionEnabled = true
        cancelIconImageView.addGestureRecognizer(cancelGestureRecognizer)
        
        changeEditStatus()
    }
    
    private func changeEditStatus() {
        isEditing = !isEditing
        editIconImageView.isHidden = isEditing
        applyIconImageView.isHidden = !isEditing
        cancelIconImageView.isHidden = !isEditing
    }
    
    private func checkCanEdit(item: BaseDataSourceItem) {
        if item.isLocalItem || item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum {
            fileNameField.isEnabled = false
        }
    }
    
    private func hideInfoDateLabels() {
        takenDateStackView.isHidden = true
        uploadDateStackView.isHidden = true
    }
    
    private func showInfoDateLabels() {
        takenDateStackView.isHidden = false
        uploadDateStackView.isHidden = false
        durationStackView.isHidden = false
    }
    
    // MARK: Actions
    
    @objc func onSave() {
        changeEditStatus()
        fileNameField.isUserInteractionEnabled = false
        if var text = fileNameField.text,
            let fileExtension = fileExtension {
            if fileExtension.count > 0,
                text.count > 0 {
                text = "\((text as NSString).deletingPathExtension).\(fileExtension)"
            }

            output.onRename(newName: text)
            output.validateName(newName: text)
        }
    }
    
    @objc func onEdit(tapGestureRecognizer: UITapGestureRecognizer) {
        changeEditStatus()
        fileNameField.isUserInteractionEnabled = true
        startRenaming()
    }
    
    @objc func onCancel() {
        changeEditStatus()
        fileNameField.isUserInteractionEnabled = false
    }
}

extension PhotoInfoViewController: FileInfoViewInput {
    func goBack() {
        
    }
    
    func startActivityIndicator() {
        
    }
    
    func stopActivityIndicator() {
        
    }
    
    func showErrorAlert(message: String) {
        
    }
    
    
    func startRenaming() {
        if fileNameField == nil {
            _ = self
        }
        fileNameField.becomeFirstResponder()
    }
    
    func setObject(object: BaseDataSourceItem) {
        showInfoDateLabels()
        fileNameField.text = object.name
        
        if let obj = object as? WrapData {
            
            if obj.fileType.typeWithDuration {
                durationLabel.text = obj.duration
            } else {
                durationStackView.isHidden = true
                layoutSubviews()
            }
            
            let formatter = ByteCountFormatter()
            formatter.countStyle = .binary
            fileSizeLabel.text = formatter.string(fromByteCount: obj.fileSize)
            
            if obj.fileType == .folder {
                fileNameTitleLabel.text = TextConstants.fileInfoFolderNameTitle
                fileInfoLabel.text = TextConstants.fileInfoFolderInfoTitle
                fileSizeTitleLabel.text = TextConstants.fileInfoAlbumSizeTitle
                fileSizeLabel.text = String(obj.childCount ?? 0)
                uploadDateTitleLabel.text = TextConstants.fileInfoCreationDateTitle
            } else {
                fileSizeTitleLabel.text = TextConstants.fileInfoFileSizeTitle
                checkCanEdit(item: object)
            }
            
            if let createdDate = obj.creationDate, !object.isLocalItem {
                uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
                if !obj.isLocalItem, let takenDate = obj.metaData?.takenDate, createdDate != takenDate {
                    takenDateLabel.text = takenDate.getDateInFormat(format: "dd MMMM yyyy")
                } else {
                    takenDateStackView.isHidden = true
                }
            } else {
                hideInfoDateLabels()
            }
            return
        }
        
        if let album = object as? AlbumItem {
            uploadDateTitleLabel.text = TextConstants.fileInfoCreationDateTitle
            fileSizeTitleLabel.text = TextConstants.fileInfoAlbumSizeTitle
            fileNameTitleLabel.text = TextConstants.fileInfoAlbumNameTitle
            fileInfoLabel.text = TextConstants.fileInfoAlbumInfoTitle
            var count = 0
            count += album.audioCount ?? 0
            count += album.imageCount ?? 0
            count += album.videoCount ?? 0
            fileSizeLabel.text = String(count)
            
            if album.readOnly == true {
                fileNameField.isEnabled = false
            }
            
            if album.fileType.isFaceImageAlbum {
                checkCanEdit(item: object)
            }
        }
        
        if let createdDate = object.creationDate {
            uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
            takenDateStackView.isHidden = true
        } else {
            hideInfoDateLabels()
        }
        
        durationStackView.isHidden = true
        layoutIfNeeded()
    }
    
    func show(name: String) {
        fileExtension = (name as NSString).pathExtension
        
        if fileNameField.isFirstResponder {
            fileNameField.text = (name as NSString).deletingPathExtension
        } else {
            fileNameField.text = name
        }
    }
    
    func showValidateNameSuccess() {
        fileNameField.resignFirstResponder()
        
        if let text = fileNameField.text,
            text.count > 0,
            let fileExtension = fileExtension,
            fileExtension.count > 0 {
            fileNameField.text = "\((text as NSString).deletingPathExtension).\(fileExtension)"
        }
    }
    
    func hideViews() {
        subviews.forEach { $0.isHidden = true }
    }
    
    func showViews() {
        subviews.forEach { $0.isHidden = false }
    }
    
}

// MARK: UITextFieldDelegate

extension PhotoInfoViewController: UITextFieldDelegate {
    
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

