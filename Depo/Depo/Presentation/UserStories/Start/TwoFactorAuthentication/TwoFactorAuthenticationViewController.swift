//
//  TwoFactorAuthenticationViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum ReasonForExtraAuth {
    case accountSetting
    case newDevice
}

enum SelectedTypeOfAuth {
    case phone
    case email
}

protocol TwoFactorAuthenticationViewControllerDelegate {
    func didSelectType(type: SelectedTypeOfAuth)
}

final class TwoFactorAuthenticationViewController: ViewController, NibInit {
    
    private struct AuthType {
        let type: SelectedTypeOfAuth
        let typeDescription: String
        let userData: String
    }
    
    @IBOutlet private var designer: TwoFactorAuthenticationDesigner!
    @IBOutlet private weak var reasonOfAuthLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    private var availableAuthTypes: [AuthType] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var reasonForAuth: ReasonForExtraAuth?
    private var phoneNumber: String?
    private var email: String?
    
    private var selectedTypeOfAuth: AuthType?
    private var selectedCellIndex: Int?
    var delegate: TwoFactorAuthenticationViewControllerDelegate?
    
    init(email: String?, phoneNumber: String?, reason: ReasonForExtraAuth) {
        self.reasonForAuth = reason
        self.email = email
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAvailableTypesArray(email: email, phoneNumber: phoneNumber)
        setSelectedItem(index: availableAuthTypes.startIndex)
        setReasonDescriptionLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    private func configureNavBarActions() {
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.twoFactorAuthenticationNavigationTitle)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.backTitle,
                                                           target: self,
                                                           selector: #selector(onBackButton))
    }
    
    @objc private func onBackButton() {
        hideViewController()
    }
    
    private func hideViewController() {
        // TODO: Delete unused method
        
        //        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    private func setReasonDescriptionLabel() {
        if let reason = reasonForAuth {
            switch reason {
            case .accountSetting:
                reasonOfAuthLabel.text = TextConstants.twoFactorAuthenticationAccountSettingReason
            case .newDevice:
                reasonOfAuthLabel.text = TextConstants.twoFactorAuthenticationNewDeviceReason
            }
        }
    }
    
    private func createAvailableTypesArray(email: String?, phoneNumber: String?) {
        if let email = email {
            let emailType = AuthType(type: .email, typeDescription: TextConstants.twoFactorAuthenticationEmailCell, userData: email)
            availableAuthTypes.append(emailType)
        }
        
        if let phoneNumber = phoneNumber {
            let phoneType = AuthType(type: .phone, typeDescription: TextConstants.twoFactorAuthenticationPhoneNumberCell, userData: phoneNumber)
            availableAuthTypes.append(phoneType)
        }
    }
    
    private func setSelectedItem(index: Int) {
        
        guard !availableAuthTypes.isEmpty, availableAuthTypes.count >= index else {
            assertionFailure()
            return
        }
        
        guard index != selectedCellIndex else {
            return
        }
        
        selectedTypeOfAuth = availableAuthTypes[index]
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TwoFactorAuthenticationCell else {
            assertionFailure()
            return
        }
        
        tableView.visibleCells.filter { $0 != cell }.forEach { cell in
            guard let cell = cell as? TwoFactorAuthenticationCell else {
                assertionFailure()
                return
            }
            
            cell.setSelected(selected: false)
        }
        
        cell.setSelected(selected: true)
    }
    
    private func isSelected(index: Int) -> Bool {
        return selectedCellIndex == index
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        if let type = selectedTypeOfAuth?.type {
            delegate?.didSelectType(type: type)
        }
        hideViewController()
    }
}

extension TwoFactorAuthenticationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableAuthTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeue(reusable: TwoFactorAuthenticationCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.delegate = self
        cell.setCellIndexPath(index: indexPath.row)
        
        let item = availableAuthTypes[indexPath.row]
        cell.setupCell(typeDescription: item.typeDescription,
                       userData: item.userData,
                       isNeedToShowSeparator: indexPath.row == availableAuthTypes.startIndex)
        
        cell.setSelected(selected: isSelected(index: indexPath.row))
        
        return cell
    }
    
}

extension TwoFactorAuthenticationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let index = selectedCellIndex else {
            return
        }

        setSelectedItem(index: index)
    }
}

extension TwoFactorAuthenticationViewController: TwoFactorAuthenticationCellDelegate {
    
    func selectButtonPressed(cell index: Int) {
        
        guard let visibleCells = tableView?.indexPathsForVisibleRows else {
            assertionFailure()
            return
        }
        
        selectedCellIndex = index
        tableView.reloadRows(at: visibleCells, with: UITableViewRowAnimation.none)
    }
}


