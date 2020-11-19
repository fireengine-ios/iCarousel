//
//  PrivateShateAccessListViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShateAccessListViewController: BaseViewController, NibInit {

    static func with(uuid: String, contact: SharedContact) -> PrivateShateAccessListViewController {
        let controller = PrivateShateAccessListViewController.initFromNib()
        controller.uuid = uuid
        controller.contact = contact
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
        
        var actionStyle: UIAlertActionStyle {
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
    
    private var uuid = ""
    private var contact: SharedContact?
    private var objects = [PrivateShareAccessListInfo]()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(withString: TextConstants.privateShareAccessTitle)
        setupTableView()
        updateAccessList()
    }
    
    private func setupTableView() {
        tableView.register(nibCell: PrivateShareAccessListCell.self)
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.separatorInset = UIEdgeInsets(topBottom: 0, rightLeft: 16)
    }
    
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
}

//MARK: - API Requests

private extension PrivateShateAccessListViewController {

    func updateAccessList() {
        guard let subjectId = contact?.subject?.identifier else {
            return
        }
        
        showSpinner()
        
        privateShareApiService.getAccessList(uuid: uuid, subjectId: subjectId) { [weak self] result in
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
    
    func updateUserRole(aclId: Int64) {
        showSpinner()
        
        privateShareApiService.updateAclRole(uuid: uuid, aclId: aclId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success(_):
                //After successful response, we need to refresh the page because other folders role may be affected
                self.updateAccessList()
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
    
    func deleteUser(aclId: Int64) {
        showSpinner()
        
        privateShareApiService.deleteAclUser(uuid: uuid, aclId: aclId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            
            switch result {
            case .success():
                //After successful response, we need to refresh the page because other folders may be affected
                self.updateAccessList()
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
        cell.setup(with: objects[indexPath.row])
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
                    self?.updateUserRole(aclId: info.id)
                }
            case .viewer:
                if info.role != .viewer {
                    self?.updateUserRole(aclId: info.id)
                }
            case .delete:
                self?.deleteUser(aclId: info.id)
            }
        }
    }
}
