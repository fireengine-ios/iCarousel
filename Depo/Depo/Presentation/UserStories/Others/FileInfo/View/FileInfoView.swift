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
    func tapGesture(recognizer: UITapGestureRecognizer)
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
    
    @IBOutlet private weak var contentView: UIStackView!
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerHandler))
        return gesture
    }()
    
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
    
    private lazy var fileNameView = FileNameView.with(delegate: self)
    private lazy var fileInfoView = FileMetaInfoView.view()
    
    // MARK: Private Properties
    
    private var fileType: FileType = .application(.unknown)
    private var status: ItemStatus = .unknown
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
    
    func setObject(_ object: BaseDataSourceItem, completion: VoidHandler?) {
        resetUI()
        fileNameView.name = object.name
        fileType = object.fileType
        
        if let obj = object as? WrapData {
            status = obj.status
            setWith(wrapData: obj)
        }
        
        if let album = object as? AlbumItem {
            setWith(albumItem: album)
        }

        if let createdDate = object.creationDate, !object.isLocalItem {
            fileInfoView.set(createdDate: createdDate)
        }
        
        layoutIfNeeded()
        completion?()
    }
    
    func show(name: String) {
        fileNameView.name = name
    }
    
    func showValidateNameSuccess() {
        fileNameView.showValidateNameSuccess()
    }
    
    func reloadCollection(with items: [PeopleOnPhotoItemResponse]) {
        let isHidden = peopleCollectionView.isHidden
        switch status {
        case .deleted, .trashed, .hidden:
            peopleCollectionView.isHidden = true
        default:
            peopleCollectionView.isHidden = items.isEmpty
        }
        premiumTextLabel.text = items.isEmpty
            ? TextConstants.noPeopleBecomePremiumText
            : TextConstants.allPeopleBecomePremiumText
        dataSource.reloadCollection(with: items)
        setHiddenPeopleLabel()
        isHidden != items.isEmpty ? layoutIfNeeded() : ()
    }
    
    func setHiddenPeoplePlaceholder(isHidden: Bool) {
        enableFIRStackView.isHidden = isHidden
        peopleCollectionView.isHidden = !isHidden
    }
    
    func setHiddenPremiumStackView(isHidden: Bool) {
        var isPremiumHidden: Bool
        switch status {
        case .deleted, .trashed, .hidden:
            isPremiumHidden = true
        default:
            isPremiumHidden = fileType == .image ? isHidden : true
        }
        premiumStackView.isHidden = isPremiumHidden
        setHiddenPeopleLabel()
    }
    
    func setWith(wrapData: WrapData) {
        if wrapData.fileType == .folder {
            fileNameView.title = TextConstants.fileInfoFolderNameTitle
        } else {
            setupEditableState(for: wrapData)
        }
        
        fileInfoView.setup(with: wrapData)
        
        if wrapData.fileType == .video {
            peopleStackView.isHidden = true
            premiumStackView.isHidden = true
        }
    }
        
    func setWith(albumItem: AlbumItem) {
        fileNameView.title = TextConstants.fileInfoAlbumNameTitle
        fileNameView.isReadOnly = albumItem.readOnly ?? false
        fileInfoView.setup(with: albumItem)
        
        if albumItem.fileType.isFaceImageAlbum {
            setupEditableState(for: albumItem)
        }
    }
    
    func hideKeyboard() {
        fileNameView.hideKeyboard()
    }
    
    // MARK: Private Methods
    
    private func setup() {
        layer.masksToBounds = true
        let views: [UIView] = [fileNameView, fileInfoView]
        
        var index = 0
        views.forEach { view in
            contentView.insertArrangedSubview(view, at: index)
            index += 1
            let separator = UIView.makeSeparator(width: contentView.frame.width, offset: 0)
            contentView.insertArrangedSubview(separator, at: index)
            index += 1
        }
        
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupEditableState(for item: BaseDataSourceItem) {
        let isHidden = (item.isLocalItem || item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum) && item.syncStatus != .synced
        fileNameView.isEditable = !isHidden
    }
    
    private func resetUI() {
        fileNameView.title = TextConstants.fileInfoFileNameTitle
        fileInfoView.reset()
        dataSource.reset()
        peopleCollectionView.isHidden = true
    }
    
    private func setHiddenPeopleLabel() {
        peopleTitleLabel.isHidden =
            premiumStackView.isHidden
            && peopleCollectionView.isHidden
            && enableFIRStackView.isHidden
    }
    
    @objc private func tapGestureRecognizerHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        output?.tapGesture(recognizer: gestureRecognizer)
    }
    
    // MARK: Actions
    
    @IBAction private func onEnableTapped(_ sender: Any) {
        output.onEnableFaceRecognitionDidTap()
    }
    
    @IBAction private func onPremiumTapped(_ sender: Any) {
        output.onBecomePremiumDidTap()
    }
}

extension FileInfoView: PeopleSliderDataSourceDelegate {
    func didSelect(item: PeopleOnPhotoItemResponse) {
        output.onPeopleAlbumDidTap(item)
    }
}

extension FileInfoView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureView = gestureRecognizer.view {
            let tapLocation = gestureRecognizer.location(in: gestureView)
            let subview = hitTest(tapLocation, with: nil)
            return subview == peopleCollectionView
        }
        return true
    }
}

extension FileInfoView: FaceImageItemsModuleOutput {
    
    func didChangeName(item: WrapData) {}
    
    func didReloadData() {}
    
    func delete(item: Item) {
        guard let peopleItem = item as? PeopleItem,
            let index = dataSource.items.firstIndex(where: { $0.personInfoId == peopleItem.id })
        else {
            return
        }
            
        dataSource.deleteItem(at: index)
        reloadCollection(with: dataSource.items)
    }
}

//MARK: - FileNameViewDelegate

extension FileInfoView: FileNameViewDelegate {
    
    func onRename(newName: String) {
        output.onRename(newName: newName)
    }
}
