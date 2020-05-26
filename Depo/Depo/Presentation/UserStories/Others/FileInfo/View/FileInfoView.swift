//
//  FileInfoView.swift
//  Depo_LifeTech
//
//  Created by Harbros12 on 5/4/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoInfoViewControllerOutput {
    func onRename(newName: String)
    func onEnableFaceRecognitionDidTap()
    func onBecomePremiumDidTap()
    func onPeopleAlbumDidTap(_ album: PeopleOnPhotoItemResponse)
}

final class FileInfoView: UIView, FromNib {
    
    // MARK: Public Properties

    var output: PhotoInfoViewControllerOutput!

    // MARK: IBOutlet
    
    @IBOutlet private weak var view: UIView!
    
    @IBOutlet private weak var backgroundView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 7
        }
    }
    
    // file name
    @IBOutlet private weak var fileNameTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoFileNameTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    @IBOutlet private weak var fileNameTextField: UITextField! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var editNameButton: UIButton!
    @IBOutlet private weak var saveNameButton: UIButton!
    @IBOutlet private weak var cancelRenamingButton: UIButton!
    
    // file info
    @IBOutlet private weak var fileInfoLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoFileInfoTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }
    
    // file size
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
    
    // duration
    @IBOutlet private weak var durationStackView: UIStackView!
    
    @IBOutlet private weak var durationTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoDurationTitle
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var durationLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    // upload date
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
    
    // taken date
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
    
    // people
    
    @IBOutlet private weak var peopleStackView: UIStackView!
    
    @IBOutlet private weak var peopleTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.myStreamPeopleTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }

    @IBOutlet private weak var peopleCollectionView: UICollectionView!

    // enableFIR
    @IBOutlet private weak var enableFIRStackView: UIStackView!
    @IBOutlet private weak var enableFIRTextLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoPeople
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var enableFIRButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitleColor(.white, for: UIControl.State())
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = ColorConstants.marineTwo
            newValue.setTitle(TextConstants.passcodeEnable, for: UIControl.State())
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    // premium
    @IBOutlet private weak var premiumStackView: UIStackView!
    
    @IBOutlet private weak var premiumTextLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var premiumButton: GradientPremiumButton! {
        willSet {
            newValue.titleEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14)
            newValue.setTitle(TextConstants.becomePremium, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 15)
        }
    }
    
    // MARK: Private Properties
    
    private var fileExtension: String?
    private let formatter = ByteCountFormatter()
    private lazy var dataSource = PeopleSliderDataSource(collectionView: peopleCollectionView, delegate: self)
    
    // MARK: Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFromNib()
        setup()
    }
    
    // MARK: Public Methods
    
    func setObject(_ object: BaseDataSourceItem) {
        resetUI()
        fileNameTextField.text = object.name
        
        if let obj = object as? WrapData {
            setWith(wrapData: obj)
        }
        
        if let album = object as? AlbumItem {
            setWith(albumItem: album)
        }
        
        if let createdDate = object.creationDate {
            uploadDateLabel.text = createdDate.getDateInFormat(format: "dd MMMM yyyy")
            uploadDateStackView.isHidden = false
        }
        
        layoutIfNeeded()
    }
    
    func show(name: String) {
        fileExtension = (name as NSString).pathExtension
        if fileNameTextField.isFirstResponder {
            fileNameTextField.text = (name as NSString).deletingPathExtension
        } else {
            fileNameTextField.text = name
        }
    }
    
    func showValidateNameSuccess() {
        fileNameTextField.resignFirstResponder()
        guard
            let text = fileNameTextField.text?.nonEmptyString,
            let fileExtension = fileExtension?.nonEmptyString
        else {
            return
        }
        fileNameTextField.text = text.makeFileName(with: fileExtension)
    }
    
    func reloadCollection(with items: [PeopleOnPhotoItemResponse]) {
        peopleCollectionView.isHidden = items.isEmpty
        premiumTextLabel.text = items.isEmpty
            ? TextConstants.noPeopleBecomePremiumText
            : TextConstants.allPeopleBecomePremiumText
        dataSource.reloadCollection(with: items)
        setHiddenPeopleLabel()
    }
    
    func setHiddenPeoplePlaceholder(isHidden: Bool) {
        enableFIRStackView.isHidden = isHidden
        peopleCollectionView.isHidden = !isHidden
        premiumStackView.isHidden = !isHidden
    }
    
    func setHiddenPremiumStackView(isHidden: Bool) {
        premiumStackView.isHidden = isHidden
        setHiddenPeopleLabel()
    }
    
    func setWith(wrapData: WrapData) {
        if wrapData.fileType.typeWithDuration {
            durationLabel.text = wrapData.duration
            durationStackView.isHidden = false
        }
                    
        formatter.countStyle = .binary
        fileSizeLabel.text = formatter.string(fromByteCount: wrapData.fileSize)
        
        if wrapData.fileType == .folder {
            fileNameTitleLabel.text = TextConstants.fileInfoFolderNameTitle
            fileInfoLabel.text = TextConstants.fileInfoFolderInfoTitle
            fileSizeTitleLabel.text = TextConstants.fileInfoAlbumSizeTitle
            fileSizeLabel.text = String(wrapData.childCount ?? 0)
            uploadDateTitleLabel.text = TextConstants.fileInfoCreationDateTitle
        } else {
            fileSizeTitleLabel.text = TextConstants.fileInfoFileSizeTitle
            setupEditableState(for: wrapData)
        }
        
        if wrapData.fileType == .video {
            peopleStackView.isHidden = true
            premiumStackView.isHidden = true
        }
        
        if let creationDate = wrapData.creationDate, !wrapData.isLocalItem {
            uploadDateLabel.text = creationDate.getDateInFormat(format: "dd MMMM yyyy")
            uploadDateStackView.isHidden = false
            
            if !wrapData.isLocalItem, let takenDate = wrapData.metaData?.takenDate, creationDate != takenDate {
                takenDateLabel.text = takenDate.getDateInFormat(format: "dd MMMM yyyy")
                takenDateStackView.isHidden = false
            }
        }
    }
        
    func setWith(albumItem: AlbumItem) {
        uploadDateTitleLabel.text = TextConstants.fileInfoCreationDateTitle
        
        fileSizeTitleLabel.text = TextConstants.fileInfoAlbumSizeTitle
        fileNameTitleLabel.text = TextConstants.fileInfoAlbumNameTitle
        fileInfoLabel.text = TextConstants.fileInfoAlbumInfoTitle
        
        var count = 0
        count += albumItem.audioCount ?? 0
        count += albumItem.imageCount ?? 0
        count += albumItem.videoCount ?? 0
        fileSizeLabel.text = String(count)
        
        if albumItem.readOnly == true {
            fileNameTextField.isEnabled = false
        }
        
        if albumItem.fileType.isFaceImageAlbum {
            setupEditableState(for: albumItem)
        }
    }
    
    func hideKeyboard() {
        fileNameTextField.resignFirstResponder()
    }
    
    // MARK: Private Methods
    
    private func setup() {
        layer.masksToBounds = true
        fileNameTextField.delegate = self
        fileNameTextField.isUserInteractionEnabled = false
        changeEditStatus(false)
    }
    
    private func changeEditStatus(_ isEditing: Bool) {
        editNameButton.isHidden = isEditing
        saveNameButton.isHidden = !isEditing
        cancelRenamingButton.isHidden = !isEditing
    }
    
    private func setupEditableState(for item: BaseDataSourceItem) {
        if item.isLocalItem || item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum {
            fileNameTextField.isEnabled = false
            editNameButton.isHidden = true
        }
    }
    
    private func resetUI() {
        resetTitleNames()
        hideInfoDateLabels()
        dataSource.reset()
        durationStackView.isHidden = true
        peopleCollectionView.isHidden = true
    }
    
    private func resetTitleNames() {
        fileInfoLabel.text = TextConstants.fileInfoFileInfoTitle
        fileNameTitleLabel.text = TextConstants.fileInfoFileNameTitle
        
        durationTitleLabel.text = TextConstants.fileInfoDurationTitle
        
        uploadDateTitleLabel.text = TextConstants.fileInfoUploadDateTitle
        takenDateTitleLabel.text = TextConstants.fileInfoTakenDateTitle
    }
    
    private func hideInfoDateLabels() {
        takenDateStackView.isHidden = true
        uploadDateStackView.isHidden = true
    }
    
    private func setHiddenPeopleLabel() {
        peopleTitleLabel.isHidden =
            premiumStackView.isHidden
            && peopleCollectionView.isHidden
            && enableFIRStackView.isHidden
    }
    
    // MARK: Actions
    
    @IBAction private func onSaveNameDidTap() {
        changeEditStatus(false)
        fileNameTextField.isUserInteractionEnabled = false
        guard
            let text = fileNameTextField.text?.nonEmptyString,
            let fileExtension = fileExtension?.nonEmptyString
        else { return }
        output.onRename(newName: text.makeFileName(with: fileExtension))
    }
    
    @IBAction private func onEditNameDidTap() {
        changeEditStatus(true)
        fileNameTextField.isUserInteractionEnabled = true
        fileNameTextField.becomeFirstResponder()
    }
    
    @IBAction private func onCancelRenamingDidTap() {
        changeEditStatus(false)
        showValidateNameSuccess()
        fileNameTextField.isUserInteractionEnabled = false
    }
    
    @IBAction private func onEnableTapped(_ sender: Any) {
        output.onEnableFaceRecognitionDidTap()
    }
    
    @IBAction private func onPremiumTapped(_ sender: Any) {
        output.onBecomePremiumDidTap()
    }
}

// MARK: UITextFieldDelegate

extension FileInfoView: UITextFieldDelegate {
    
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

extension FileInfoView: PeopleSliderDataSourceDelegate {
    func didSelect(item: PeopleOnPhotoItemResponse) {
        output.onPeopleAlbumDidTap(item)
    }
}
