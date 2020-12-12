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
    func onSelectSharedContact(_ contact: SharedContact)
    func onAddNewShare()
    func showWhoHasAccess(shareInfo: SharedFileInfo)
    func didUpdateSharingInfo(_ sharingInfo: SharedFileInfo)
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

    // MARK: Private Properties
    
    private lazy var fileNameView = FileNameView.with(delegate: self)
    private lazy var fileInfoView = FileMetaInfoView.view()
    private lazy var peopleView = FileInfoPeopleView.with(delegate: self)
    private lazy var sharingInfoView = FileInfoShareView.with(delegate: self)
    
    private lazy var localContactsService = ContactsSuggestionServiceImpl()
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var analytics = PrivateShareAnalytics()
    
    private var object: BaseDataSourceItem?
    
    // MARK: Life cycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
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
        self.object = object
        resetUI()
        fileNameView.name = object.name
        peopleView.fileType = object.fileType
        
        if let obj = object as? WrapData {
            peopleView.status = obj.status
            setWith(wrapData: obj)
        }
        
        if let album = object as? AlbumItem {
            setWith(albumItem: album)
        }

        if let createdDate = object.creationDate, !object.isLocalItem {
            fileInfoView.set(createdDate: createdDate)
        }
        
        updateShareInfo()
        
        setupEditableState(for: object, projectId: object.projectId, permissions: nil)
        
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
        peopleView.reload(with: items)
    }
    
    func setHiddenPeoplePlaceholder(isHidden: Bool) {
        peopleView.setHiddenPeoplePlaceholder(isHidden: isHidden)
    }
    
    func setHiddenPremiumStackView(isHidden: Bool) {
        peopleView.setHiddenPremiumStackView(isHidden: isHidden)
    }
    
    func setWith(wrapData: WrapData) {
        if wrapData.fileType == .folder {
            fileNameView.title = TextConstants.fileInfoFolderNameTitle
        }
        
        fileInfoView.setup(with: wrapData)
        
        if wrapData.fileType == .video {
            peopleView.isHidden = true
        }
    }
        
    func setWith(albumItem: AlbumItem) {
        fileNameView.title = TextConstants.fileInfoAlbumNameTitle
        fileNameView.isEditable = albumItem.readOnly ?? false
        fileInfoView.setup(with: albumItem)
    }
    
    func hideKeyboard() {
        fileNameView.hideKeyboard()
    }
    
    func updateShareInfo() {
        guard object?.isLocalItem == false, let projectId = object?.projectId, let uuid = object?.uuid else {
            return
        }
        getSharingInfo(projectId: projectId, uuid: uuid)
    }
    
    func setHiddenShareInfoView(isHidden: Bool) {
        sharingInfoView.isHidden = isHidden
    }
    
    // MARK: Private Methods
    
    private func setup() {
        layer.masksToBounds = true
        let views: [UIView] = [fileNameView, fileInfoView, sharingInfoView, peopleView]
        
        sharingInfoView.isHidden = true
        
        views.forEach { contentView.addArrangedSubview($0) }
        
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
        ItemOperationManager.default.startUpdateView(view: self)
    }
    
    private func setupEditableState(for item: BaseDataSourceItem, projectId: String?, permissions: SharedItemPermission?) {
        var canEdit = true
        if projectId != SingletonStorage.shared.accountInfo?.projectID {
            canEdit = permissions?.granted?.contains(.setAttribute) == true
        }
        
        if (item.isLocalItem || item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum) && item.syncStatus != .synced {
            canEdit = false
        }

        fileNameView.isEditable = canEdit
    }
    
    private func resetUI() {
        fileNameView.title = TextConstants.fileInfoFileNameTitle
        fileInfoView.reset()
        peopleView.reset()
        sharingInfoView.isHidden = true
    }
    
    @objc private func tapGestureRecognizerHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        output?.tapGesture(recognizer: gestureRecognizer)
    }
    
    private func getSharingInfo(projectId: String, uuid: String) {
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        var hasAccess = false
        var sharingInfo: SharedFileInfo?
        
        localContactsService.fetchAllContacts { isAuthorized in
            hasAccess = isAuthorized
            group.leave()
        }
            
        shareApiService.getSharingInfo(projectId: projectId, uuid: uuid) { result in
            switch result {
            case .success(let info):
                sharingInfo = info
            case .failed(let error):
                //we can't show alert here because BE always return error after manual sync photo from preview
                debugPrint("getSharingInfo error - \(error.description)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            if let sharingInfo = sharingInfo {
                self?.setupSharingInfoView(sharingInfo: sharingInfo, hasAccess: hasAccess)
            }
        }
    }
    
    private func setupSharingInfoView(sharingInfo: SharedFileInfo, hasAccess: Bool) {
        let needShow = sharingInfo.members?.isEmpty == false
        
        if needShow {
            var info = sharingInfo
            info.members?.enumerated().forEach { index, member in
                let localContactNames = localContactsService.getContactName(for: member.subject?.username ?? "", email: member.subject?.email ?? "")
                info.members?[index].subject?.name = displayName(from: localContactNames)
            }
            sharingInfoView.setup(with: info)
        }
        
        if let object = object {
            setupEditableState(for: object, projectId: sharingInfo.projectId, permissions: sharingInfo.permissions)
        }
        
        if sharingInfoView.isHidden && needShow {
            analytics.trackScreen(.shareInfo)
        }
        
        sharingInfoView.isHidden = !needShow
        output.didUpdateSharingInfo(sharingInfo)
    }
    
    private func displayName(from localNames: LocalContactNames) -> String {
        if !localNames.givenName.isEmpty, !localNames.familyName.isEmpty {
            return "\(localNames.givenName) \(localNames.familyName)"
        } else if !localNames.givenName.isEmpty {
            return localNames.givenName
        } else {
            return localNames.familyName
        }
    }
}

extension FileInfoView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureView = gestureRecognizer.view {
            let tapLocation = gestureRecognizer.location(in: gestureView)
            let subview = hitTest(tapLocation, with: nil)
            return subview == peopleView.collectionView
        }
        return true
    }
}

extension FileInfoView: FaceImageItemsModuleOutput {
    
    func didChangeName(item: WrapData) {}
    
    func didReloadData() {}
    
    func delete(item: Item) {
        peopleView.delete(item: item)
    }
}

//MARK: - FileNameViewDelegate

extension FileInfoView: FileNameViewDelegate {
    
    func onRename(newName: String) {
        output.onRename(newName: newName)
    }
}

//MARK: - FileInfoPeopleViewDelegate

extension FileInfoView: FileInfoPeopleViewDelegate {
    
    func onPeopleAlbumDidTap(item: PeopleOnPhotoItemResponse) {
        output.onPeopleAlbumDidTap(item)
    }
    
    func onEnableFaceRecognitionDidTap() {
        output.onEnableFaceRecognitionDidTap()
    }
    
    func onBecomePremiumDidTap() {
        output.onBecomePremiumDidTap()
    }
}

//MARK: - FileInfoShareViewDelegate

extension FileInfoView: FileInfoShareViewDelegate {
    
    func didSelect(contact: SharedContact) {
        output.onSelectSharedContact(contact)
    }
    
    func didTappedPlusButton() {
        output.onAddNewShare()
    }
    
    func didTappedArrowButton() {
        if let shareInfo = sharingInfoView.info {
            output.showWhoHasAccess(shareInfo: shareInfo)
        }
    }
}

//MARK: - ItemOperationManagerViewProtocol

extension FileInfoView: ItemOperationManagerViewProtocol {
    
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        object === self
    }
    
    func didShare(items: [BaseDataSourceItem]) {
        if items.first(where: { $0.uuid == object?.uuid }) != nil {
            updateShareInfo()
        }
    }
    
    func didEndShareItem(uuid: String) {
        if uuid == object?.uuid {
            updateShareInfo()
        }
    }
    
    func didChangeRole(_ role: PrivateShareUserRole, contact: SharedContact, uuid: String) {
        if uuid == object?.uuid, sharingInfoView.info?.members?.contains(contact) == true {
            updateShareInfo()
        }
    }
    
    func didRemove(contact: SharedContact, fromItem uuid: String) {
        if uuid == object?.uuid, sharingInfoView.info?.members?.contains(contact) == true {
            updateShareInfo()
        }
    }
}
