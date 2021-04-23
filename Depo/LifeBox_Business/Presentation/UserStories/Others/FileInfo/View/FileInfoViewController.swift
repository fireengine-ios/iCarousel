//
//  FileInfoViewController.swift
//  Depo
//
//  Created by Anton Ignatovich on 23.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class FileInfoViewController: BaseViewController, ActivityIndicator, ErrorPresenter {

    private var fileExtension: String?

    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.backgroundColor = ColorConstants.tableBackground.color
        }
    }
    private var fileInfoTableViewAdapter: FileInfoTableViewAdapter!

    var output: FileInfoViewOutput!
    var interactor: FileInfoInteractor!
    private var fileType: FileType = .unknown {
        didSet {
            title = fileType == .folder ? TextConstants.infoPageTitleForFolder : TextConstants.infoPageTitleForFile
        }
    }

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLargeTitle(prefersLargeTitles: false, barStyle: .white)
        fileInfoTableViewAdapter = FileInfoTableViewAdapter(with: tableView,
                                                            delegate: self)
        output.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        interactor.getEntityInfo()
    }

    private func setupNavigationBar() {
        title = fileType == .folder ? TextConstants.infoPageTitleForFolder : TextConstants.infoPageTitleForFile
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        setNavigationBarStyle(.white)
    }
}

// MARK: FileInfoViewInput
extension FileInfoViewController: FileInfoViewInput {
    func showProgress() {
        showSpinner()
    }

    func hideProgress() {
        hideSpinner()
    }

    func goBack() {
        navigationController?.popViewController(animated: true)
    }

    func setObject(_ object: BaseDataSourceItem) {
        guard let wrappedData = object as? WrapData else {
            return
        }
        fileType = wrappedData.isFolder ?? false ? .folder : .unknown
        fileInfoTableViewAdapter.update(with: wrappedData)
    }

    func hideViews() {
        tableView.isHidden = true
    }

    func showViews() {
        tableView.isHidden = false
    }

    func showEntityInfo(_ sharingInfo: SharedFileInfo) {
        fileType = sharingInfo.folder ?? false ? .folder : .unknown
        fileInfoTableViewAdapter.update(with: sharingInfo)
    }
}

//MARK: - FileInfoTableViewAdapterDelegate
extension FileInfoViewController: FileInfoTableViewAdapterDelegate {

    func didSelect(contact: SharedContact, adapter: FileInfoTableViewAdapter) {
        output.openShareAccessList(contact: contact)
    }

    func didTappedPlusButton(adapter: FileInfoTableViewAdapter) {
        output.shareItem()
    }

    func didTappedArrowButton(sharedFileInfo: SharedFileInfo, adapter: FileInfoTableViewAdapter) {
        output.showWhoHasAccess(shareInfo: sharedFileInfo)
    }
}
