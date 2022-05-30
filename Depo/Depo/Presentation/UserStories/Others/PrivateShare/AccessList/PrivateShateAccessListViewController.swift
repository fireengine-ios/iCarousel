//
//  PrivateShateAccessListViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShateAccessListViewController: BaseViewController, NibInit {

    static func with(projectId: String, uuid: String, contact: SharedContact, fileType: FileType) -> PrivateShateAccessListViewController {
        let controller = PrivateShateAccessListViewController.initFromNib()
        controller.projectId = projectId
        controller.uuid = uuid
        controller.contact = contact
        controller.fileType = fileType
        return controller
    }
    
    private enum SelectionRole: CaseIterable {
        case editor
        case viewer
        case delete
        
        var title: String {
            switch self {
            case .editor:
                return TextConstants.privateShareAccessEditor
            case .viewer:
                return TextConstants.privateShareAccessViewer
            case .delete:
                return TextConstants.privateShareAccessRemove
            }
        }
        
        var actionStyle: UIAlertAction.Style {
            switch self {
            case .editor, .viewer:
                return .default
            case .delete:
                return .destructive
            }
        }
        
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var privateShareApiService = PrivateShareApiServiceImpl()
    private lazy var router = RouterVC()
    private let analytics = PrivateShareAnalytics()
    
    private var projectId = ""
    private var uuid = ""
    private var contact: SharedContact?
    private var fileType: FileType = .unknown
    private var objects = [PrivateShareAccessListInfo]()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(withString: TextConstants.privateShareAccessTitle)
        setupTableView()
        updateAccessList()
        analytics.trackScreen(.sharedAccess)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard tableView.tableHeaderView == nil, let member = contact?.subject else {
            return
        }
        
        let username = member.username ?? member.email ?? ""
        
        if (member.name ?? "").isEmpty == false || username.isEmpty == false {
            let header = PrivateShareAccessListHeader.with(name: contact?.subject?.name, username: username)
            let size = header.sizeToFit(width: tableView.bounds.width)
            header.frame.size = size
            
            tableView.tableHeaderView = header
        }
    }
    
    private func setupTableView() {
        tableView.register(nibCell: PrivateShareAccessListCell.self)
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(topBottom: 0, rightLeft: 16)
        tableView.tableFooterView = UIView()
    }
    
    private func showRoleSelectionMenu(sender: UIButton, handler: @escaping ValueHandler<SelectionRole>) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = AppColor.blackColor.color
        
        SelectionRole.allCases.forEach { role in
            let action = UIAlertAction(title: role.title, style: role.actionStyle) { _ in
                handler(role)
            }
            actionSheet.addAction(action)
        }

        let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        actionSheet.popoverPresentationController?.sourceView = sender

        present(actionSheet, animated: true)
    }
    
    private func showDeleteConfirmationPopup(handler: @escaping BoolHandler) {
        func close(controller: PopUpController, result: Bool) {
            controller.close {
                handler(result)
            }
        }
        
        let popup = PopUpController.with(title: nil,
                                         message: TextConstants.privateShareAccessDeleteConfirmPopupMessage,
                                         image: .question,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: { vc in
                                            close(controller: vc, result: false)
                                         },
                                         secondAction: { vc in
                                            close(controller: vc, result: true)
                                         })
        router.presentViewController(controller: popup)
    }
}

//MARK: - API Requests

private extension PrivateShateAccessListViewController {

    func updateAccessList() {
        guard let subjectId = contact?.subject?.identifier else {
            return
        }
        
        showSpinner()
        
        privateShareApiService.getAccessList(projectId: projectId, uuid: uuid, subjectId: subjectId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(let objects):
                self.objects = objects
                self.tableView.reloadData()
                
                if objects.isEmpty {
                    //TODO: back and refresh previos page
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    func updateUserRole(newRole: PrivateShareUserRole, oldRole: PrivateShareUserRole, aclId: Int64, uuid: String) {
        showSpinner()
        
        privateShareApiService.updateAclRole(newRole: newRole, projectId: projectId, uuid: uuid, aclId: aclId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success():
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateShareAccessRoleChangeSuccess)
                
                if let contact = self.contact {
                    ItemOperationManager.default.didChangeRole(newRole, contact: contact, uuid: uuid)
                }
                
                if newRole == .editor, oldRole == .viewer {
                    self.analytics.changeRoleFromViewerToEditor()
                } else if newRole == .viewer, oldRole == .editor {
                    self.analytics.changeRoleFromEditorToViewer()
                }
                
                self.updateAccessList()
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    func deleteUser(aclId: Int64, uuid: String) {
        showSpinner()
        
        privateShareApiService.deleteAclUser(projectId: projectId, uuid: uuid, aclId: aclId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success():
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateShareAccessDeleteUserSuccess)
                if let contact = self.contact {
                    ItemOperationManager.default.didRemove(contact: contact, fromItem: uuid)
                }
                
                self.analytics.removeFromShare()
                
                if self.objects.count == 1 {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.updateAccessList()
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension PrivateShateAccessListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: PrivateShareAccessListCell.self, for: indexPath)
        
        let object = objects[indexPath.row]
        if object.object.uuid == uuid {
            cell.setup(with: object, fileType: fileType, isRootItem: true)
        } else {
            cell.setup(with: object, fileType: .folder, isRootItem: false)
        }
        
        cell.delegate = self
        return cell
    }
}

//MARK: - PrivateShareAccessListCellDelegate

extension PrivateShateAccessListViewController: PrivateShareAccessListCellDelegate {
    
    func onRoleTapped(sender: UIButton, info: PrivateShareAccessListInfo) {
        showRoleSelectionMenu(sender: sender) { [weak self] role in
            switch role {
            case .editor:
                if info.role != .editor {
                    self?.updateUserRole(newRole: .editor, oldRole: info.role, aclId: info.id, uuid: info.object.uuid)
                }
            case .viewer:
                if info.role != .viewer {
                    self?.updateUserRole(newRole: .viewer, oldRole: info.role, aclId: info.id, uuid: info.object.uuid)
                }
            case .delete:
                self?.showDeleteConfirmationPopup { [weak self] isConfirm in
                    if isConfirm {
                        self?.deleteUser(aclId: info.id, uuid: info.object.uuid)
                    }
                }
            }
        }
    }
}
