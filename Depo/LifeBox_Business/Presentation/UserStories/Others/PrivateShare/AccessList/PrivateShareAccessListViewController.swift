//
//  PrivateShareAccessListViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum SelectionRole: CaseIterable {
    case editor
    case viewer
    case delete
    
    var title: String {
        switch self {
        case .editor:
            return TextConstants.PrivateShare.role_editor
        case .viewer:
            return TextConstants.PrivateShare.role_viewer
        case .delete:
            return TextConstants.privateShareAccessRemove
        }
    }
    
    var actionStyle: UIAlertActionStyle {
        switch self {
        case .editor, .viewer:
            return .default
        case .delete:
            return .destructive
        }
    }
    
}


final class PrivateShareAccessListViewController: BaseViewController, NibInit {

    static func with(projectId: String, uuid: String, contact: SharedContact, fileType: FileType) -> PrivateShareAccessListViewController {
        let controller = PrivateShareAccessListViewController.initFromNib()
        controller.projectId = projectId
        controller.uuid = uuid
        controller.contact = contact
        controller.fileType = fileType
        return controller
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        willSet {
            newValue.backgroundColor = ColorConstants.tableBackground
        }
    }
    
    private lazy var privateShareApiService = PrivateShareApiServiceImpl()
    private lazy var router = RouterVC()
    private let analytics = PrivateShareAnalytics()
    
    private var projectId = ""
    private var uuid = ""
    private var contact: SharedContact?
    private var fileType: FileType = .unknown
    private var objects: [PrivateShareAccessListInfo] = []

    private var tableAdapter: PrivateShareAccessTableViewAdapter!
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAccessList()
        analytics.trackScreen(.sharedAccess)
        tableAdapter = PrivateShareAccessTableViewAdapter(with: tableView,
                                                          delegate: self)
        tableAdapter.update(with: contact,
                            uuid: uuid,
                            fileType: fileType,
                            and: objects)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        title = TextConstants.accessPageTitle
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.topItem?.backBarButtonItem = nil
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(dismissSelf(_:)))
        whiteNavBarStyle(tintColor: ColorConstants.infoPageItemBottomText,
                         titleTextColor: ColorConstants.infoPageItemBottomText)
    }

    @objc private func dismissSelf(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Presenting actions
private extension PrivateShareAccessListViewController {
    private func showRoleSelectionMenu(sender: UIButton, handler: @escaping ValueHandler<SelectionRole>) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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
private extension PrivateShareAccessListViewController {
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
                self.tableAdapter.update(with: self.contact,
                                         uuid: self.uuid,
                                         fileType: self.fileType,
                                    and: objects)
                
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

//MARK: - PrivateShareAccessTableViewAdapterDelegate

extension PrivateShareAccessListViewController: PrivateShareAccessTableViewAdapterDelegate {
    func onExactRoleDecisionTapped(_ type: ElementTypes,
                                   _ info: PrivateShareAccessListInfo,
                                   _ adapter: PrivateShareAccessTableViewAdapter) {
        switch type {
        case .editorRole:
            changeToEditorRoleIfNeeded(info: info)
        case .viewerRole:
            changeToViewerRoleIfNeeded(info: info)
        case .removeRole:
            removeRoleWithConfirmationPopup(info: info)
        default:
            break
        }
    }

    func onRoleTapped(sender: UIButton,
                      info: PrivateShareAccessListInfo,
                      _ adapter: PrivateShareAccessTableViewAdapter) {
        showRoleSelectionMenu(sender: sender) { [weak self] role in
            switch role {
            case .editor:
                self?.changeToEditorRoleIfNeeded(info: info)
            case .viewer:
                self?.changeToViewerRoleIfNeeded(info: info)
            case .delete:
                self?.removeRoleWithConfirmationPopup(info: info)
            }
        }
    }
}

private extension PrivateShareAccessListViewController {
    private func changeToEditorRoleIfNeeded(info: PrivateShareAccessListInfo) {
        if info.role != .editor {
            updateUserRole(newRole: .editor, oldRole: info.role, aclId: info.id, uuid: info.object.uuid)
        }
    }

    private func changeToViewerRoleIfNeeded(info: PrivateShareAccessListInfo) {
        if info.role != .viewer {
            updateUserRole(newRole: .viewer, oldRole: info.role, aclId: info.id, uuid: info.object.uuid)
        }
    }

    private func removeRoleWithConfirmationPopup(info: PrivateShareAccessListInfo) {
        showDeleteConfirmationPopup { [weak self] isConfirm in
            if isConfirm {
                self?.deleteUser(aclId: info.id, uuid: info.object.uuid)
            }
        }
    }
}
