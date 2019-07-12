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
        let typeDescriptin: String
        let userData: String
    }

    @IBOutlet private var designer: TwoFactorAuthenticationDesigner!
    @IBOutlet private weak var reasonOfAuthLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
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
        setupTableView()
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
    
    private func setupTableView() {
        tableViewHeightConstraint.constant = tableView.contentSize.height
        tableView.invalidateIntrinsicContentSize()
    }
    
    @objc private func onBackButton() {
        hideViewController()
    }
    
    private func hideViewController() {
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
            let emailType = AuthType(type: .email, typeDescriptin: TextConstants.twoFactorAuthenticationEmailCell, userData: email)
            availableAuthTypes.append(emailType)
        }
        
        if let phoneNumber = phoneNumber {
            let phoneType = AuthType(type: .phone, typeDescriptin: TextConstants.twoFactorAuthenticationPhoneNumberCell, userData: phoneNumber)
            availableAuthTypes.append(phoneType)
        }
    }
    
    private func setSelectedItem(index: Int) {
        guard !availableAuthTypes.isEmpty else {
            return
        }
        
        if availableAuthTypes.count >= index {
            selectedTypeOfAuth = availableAuthTypes[index]
            selectedCellIndex = index
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
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
        let settingCell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.twoFactorAuthenticationCell, for: indexPath)
        
        guard let cell = settingCell as? TwoFactorAuthenticationCell else {
            assertionFailure("Unexpected cell type")
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.setCellIndexPath(index: indexPath.row)
        
        cell.setCellOutlets(typeDescription: availableAuthTypes[indexPath.row].typeDescriptin, userData: availableAuthTypes[indexPath.row].userData, isNeedToShowSeparator: indexPath.row == availableAuthTypes.startIndex)

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
        setSelectedItem(index: indexPath.row)
    }
}

extension TwoFactorAuthenticationViewController: TwoFactorAuthenticationCellDelegate {
    func selectButtonPressed(cell index: Int) {
        setSelectedItem(index: index)
    }
}


