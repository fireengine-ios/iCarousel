//
//  TwoFactorAuthenticationViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum ReasonForExtraAuth: String {
    case accountSetting = "ACCOUNT_SETTING"
    case newDevice = "NEW_DEVICE"
}

enum AvailableTypesOfAuth: String {
    case phone = "EMAIL_OTP"
    case email = "SMS_OTP"
}

protocol TwoFactorAuthenticationViewControllerDelegate {
    func didSelectType(type: AvailableTypesOfAuth)
}

final class TwoFactorAuthenticationViewController: ViewController, NibInit {
    
    private struct AuthType {
        let type: AvailableTypesOfAuth
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
    
    private var twoFactorAuthResponse: TwoFactorAuthErrorResponse?
    private var reasonForAuth: ReasonForExtraAuth?
    private var phoneNumber: String?
    private var email: String?
    
    private var selectedTypeOfAuth: AuthType?
    private var selectedCellIndex: Int?
    var delegate: TwoFactorAuthenticationViewControllerDelegate?
    
    init(response: TwoFactorAuthErrorResponse) {
        self.twoFactorAuthResponse = response
        self.reasonForAuth = response.reason
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createAvailableTypesArray(availableTypes: twoFactorAuthResponse?.challengeTypes)
        setReasonDescriptionLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    private func configureNavBarActions() {
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.twoFactorAuthenticationNavigationTitle)
        backButtonForNavigationItem(title: TextConstants.backTitle)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.backTitle,
                                                           target: self,
                                                           selector: #selector(onBackButton))
    }
    
    @objc private func onBackButton() {
        hideViewController()
    }
    
    private func hideViewController() {
        navigationController?.popViewController(animated: true)
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
    
    private func createAvailableTypesArray(availableTypes: [TwoFactorAuthErrorResponseChallengeType]?) {
        
        guard let types = availableTypes else {
            assertionFailure()
            return
        }
        
        for item in types {
            switch item.type {
            case .phone?:
                let phoneType = AuthType(type: .phone, typeDescription: TextConstants.twoFactorAuthenticationPhoneNumberCell, userData: item.displayName ?? "")
                availableAuthTypes.append(phoneType)
            case .email?:
                let phoneType = AuthType(type: .phone, typeDescription: TextConstants.twoFactorAuthenticationPhoneNumberCell, userData: item.displayName ?? "")
                availableAuthTypes.append(phoneType)
            default:
                assertionFailure()
            }
        }
    
        if !availableAuthTypes.isEmpty {
            selectedCellIndex = availableAuthTypes.startIndex
            updateCellsAfterSelection()
        }
    }
    
    private func updateCellsAfterSelection() {
        guard let selectedCellIndex = selectedCellIndex else {
            assertionFailure()
            return
        }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: selectedCellIndex, section: 0)) as? TwoFactorAuthenticationCell else {
            assertionFailure()
            return
        }
        
        cell.setSelected(selected: true)
        
        /// deselect cells
        tableView.visibleCells
            .filter { $0 != cell }
            .compactMap { $0 as? TwoFactorAuthenticationCell }
            .forEach { $0.setSelected(selected: false) }
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
        return tableView.dequeue(reusable: TwoFactorAuthenticationCell.self, for: indexPath)
    }
}

extension TwoFactorAuthenticationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? TwoFactorAuthenticationCell else {
            assertionFailure()
            return
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.setCellIndexPath(index: indexPath.row)
        
        let item = availableAuthTypes[indexPath.row]
        cell.setupCell(typeDescription: item.typeDescription,
                       userData: item.userData,
                       isNeedToShowSeparator: indexPath.row == availableAuthTypes.startIndex)
    }
}

extension TwoFactorAuthenticationViewController: TwoFactorAuthenticationCellDelegate {
    
    func selectButtonPressed(cell index: Int) {
        
        guard index != selectedCellIndex else {
            return
        }
        
        selectedCellIndex = index
        updateCellsAfterSelection()
    }
}


