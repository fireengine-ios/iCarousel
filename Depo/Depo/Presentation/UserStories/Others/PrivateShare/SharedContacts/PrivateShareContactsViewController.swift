//
//  PrivateShareContactsViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/17/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareContactsViewController: BaseViewController, NibInit {

    static func with(shareInfo: SharedFileInfo, endShareHandler: VoidHandler?) -> PrivateShareContactsViewController {
        let controller = PrivateShareContactsViewController.initFromNib()
        controller.shareInfo = shareInfo
        controller.contacts = (shareInfo.members ?? []).sorted(by: { $0.role.order < $1.role.order })
        controller.endShareHandler = endShareHandler
        return controller
    }
    
    @IBOutlet private weak var contactsTableView: UITableView!
    @IBOutlet private weak var endSharingButton: WhiteButtonWithRoundedCorner!  {
        willSet {
            newValue.setTitle(TextConstants.privateShareWhoHasAccessEndShare, for: .normal)
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
            newValue.setTitleColor(ColorConstants.marineTwo, for: .normal)
            newValue.insets = UIEdgeInsets(topBottom: 5, rightLeft: 30)
            newValue.layer.borderColor = ColorConstants.marineTwo.cgColor
            newValue.layer.borderWidth = 1
        }
    }
    
    private var endShareHandler: VoidHandler?
    private var shareInfo: SharedFileInfo?
    private var contacts = [SharedContact]()
    
    private lazy var router = RouterVC()
    private lazy var privateShareApiService = PrivateShareApiServiceImpl()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.privateShareWhoHasAccessTitle)
        setupTableView()
        
        if shareInfo?.permissions?.granted?.contains(.writeAcl) == true {
            endSharingButton.isHidden = false
            contactsTableView.contentInset.bottom = view.frame.height - endSharingButton.frame.minY
        } else {
            endSharingButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }

    private func setupTableView() {
        contactsTableView.register(nibCell: PrivateShareContactCell.self)
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        contactsTableView.tableFooterView = UIView()
        contactsTableView.separatorInset = UIEdgeInsets(topBottom: 0, rightLeft: 16)
    }
    
    @IBAction private func onEndShare() {
        showSharePopup()
    }
    
    private func showSharePopup() {
        let popup = PopUpController.with(title: nil,
                                         message: TextConstants.privateShareWhoHasAccessPopupMessage,
                                         image: .question,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: { vc in
                                            vc.close()
                                         },
                                         secondAction: { [weak self] vc in
                                            vc.close { [weak self] in
                                                self?.endShare()
                                            }
                                         })
        router.presentViewController(controller: popup)
    }
    
    private func endShare() {
        guard let uuid = shareInfo?.uuid else {
            return
        }
        
        showSpinner()
        
        privateShareApiService.endShare(uuid: uuid) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.hideSpinner()
            switch result {
            case .success:
                self.endShareHandler?()
                self.router.popViewController()
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateShareEndShareSuccess)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension PrivateShareContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: PrivateShareContactCell.self, for: indexPath)
        cell.delegate = self
        cell.setup(with: contacts[indexPath.row], index: indexPath.row)
        return cell
    }
}

//MARK: - UITableViewDelegate

extension PrivateShareContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onRoleTapped(index: indexPath.row)
    }
}

//MARK: - PrivateShareContactCellDelegate

extension PrivateShareContactsViewController: PrivateShareContactCellDelegate {
    func onRoleTapped(index: Int) {
        guard let contact = contacts[safe: index], contact.role != .owner else {
            return
        }
        //TODO: COF-585 open access page
    }
}
