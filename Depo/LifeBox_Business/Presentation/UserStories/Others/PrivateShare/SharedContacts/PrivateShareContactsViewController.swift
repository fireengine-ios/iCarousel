//
//  PrivateShareContactsViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareContactsViewController: BaseViewController, NibInit {

    static func with(shareInfo: SharedFileInfo) -> PrivateShareContactsViewController {
        let controller = PrivateShareContactsViewController.initFromNib()
        controller.shareInfo = shareInfo
        return controller
    }
    
    @IBOutlet private weak var contactsTableView: UITableView! {
        willSet {
            newValue.backgroundColor = ColorConstants.tableBackground
        }
    }

    private var privateShareContactTableViewAdapter: PrivateShareContactTableViewAdapter!
    private var shareInfo: SharedFileInfo?
    
    private lazy var router = RouterVC()
    private lazy var privateShareApiService = PrivateShareApiServiceImpl()
    private let analytics = PrivateShareAnalytics()
    
    //MARK: - View lifecycle
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViewAdapter()
        ItemOperationManager.default.startUpdateView(view: self)
        analytics.trackScreen(.whoHasAccess)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        fetchFreshDataAboutContactsFromServer()
    }

    private func setupNavigationBar() {
        title = TextConstants.sharedContactsPageTitle
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.topItem?.backButtonTitle = ""
        whiteNavBarStyle(tintColor: ColorConstants.infoPageItemBottomText,
                         titleTextColor: ColorConstants.infoPageItemBottomText)
    }

    private func setupTableViewAdapter() {
        privateShareContactTableViewAdapter = PrivateShareContactTableViewAdapter(with: contactsTableView,
                                                                                  delegate: self)
        if let shareInfo = shareInfo {
            privateShareContactTableViewAdapter.update(with: shareInfo)
        }
    }

    private func fetchFreshDataAboutContactsFromServer() {
        guard let shareInfo = shareInfo else {
            return
        }

        privateShareApiService.getRemoteEntityInfo(projectId: shareInfo.accountUuid,
                                                   uuid: shareInfo.uuid) { [weak self] result in
            switch result {
            case .success(let info):
                self?.shareInfo = info
                if info.members?.isEmpty == true {
                    self?.navigationController?.popViewController(animated: true)
                }
                self?.privateShareContactTableViewAdapter.update(with: info)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - ItemOperationManagerViewProtocol

extension PrivateShareContactsViewController: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        object === self
    }

    func didChangeRole(_ role: PrivateShareUserRole, contact: SharedContact, uuid: String) {
        guard
            var shareInfoInner = shareInfo,
            var contacts = shareInfoInner.members,
              shareInfoInner.uuid == uuid
        else {
            return
        }

        if let index = contacts.firstIndex(where: { $0 == contact }) {
            contacts[index].role = role
            contacts.sort(by: { $0.role.order < $1.role.order })
        }
        shareInfoInner.members = contacts
        shareInfo = shareInfoInner
        privateShareContactTableViewAdapter.update(with: shareInfoInner)
    }

    func didRemove(contact: SharedContact, fromItem uuid: String) {
        guard
            var shareInfoInner = shareInfo,
            var contacts = shareInfoInner.members,
              shareInfoInner.uuid == uuid
        else {
            return
        }

        contacts.remove(contact)
        shareInfoInner.members = contacts
        shareInfo = shareInfoInner
        privateShareContactTableViewAdapter.update(with: shareInfoInner)
    }
}

// MARK: - PrivateShareTableViewAdapterDelegate
extension PrivateShareContactsViewController: PrivateShareContactTableViewAdapterDelegate {
    func didTapOnContact(_ contact: SharedContact, adapter: PrivateShareContactTableViewAdapter) {
        guard shareInfo?.permissions?.granted?.contains(.writeAcl) == true else {
            return
        }

        guard
            contact.role.isContained(in: [.editor, .viewer]),
            let accountUuid = shareInfo?.accountUuid,
            let uuid = shareInfo?.uuid,
            let fileType = shareInfo?.fileType
        else {
            return
        }

        let controller = router.privateShareAccessList(projectId: accountUuid,
                                                       uuid: uuid,
                                                       contact: contact,
                                                       fileType: fileType)
        let navC = UINavigationController(rootViewController: controller)
        router.presentViewController(controller: navC)
    }
}
