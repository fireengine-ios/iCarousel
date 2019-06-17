//
//  TermsAndPolicyViewController.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class TermsAndPolicyViewController: BaseViewController, NibInit {
    
    @IBOutlet weak var tableView: UITableView!
    private var listOfItems = [TextConstants.termsOfUseCell, TextConstants.privacyPolicyCell]
    
    private let router = RouterVC()
    private let eulaService = EulaService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setTitle(withString: TextConstants.settingsViewCellPrivacyAndTerms)
    }
    
    private func setupTableView() {
        let nib = UINib.init(nibName: CellsIdConstants.settingTableViewCellID,
                             bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.settingTableViewCellID)
        tableView.backgroundColor = UIColor.clear
    }
}

extension TermsAndPolicyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let settingCell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.settingTableViewCellID, for: indexPath)
        
        guard let cell = settingCell as? SettingsTableViewCell else {
            assertionFailure("Unexpected cell type")
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let item = listOfItems[indexPath.row]
        cell.setTextForLabel(titleText: item, needShowSeparator: indexPath.row == listOfItems.count - 1)
        
        return cell
    }
}

extension TermsAndPolicyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.row {
        case 0:
            goToTermsOfUse()
        case 1:
            goToPrivacyPolicy()
        default:
            assertionFailure()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}

extension TermsAndPolicyViewController {
    
    private func goToTermsOfUse() {
        eulaService.getTermOfUse { [weak self] response in
            switch response {
            case .success(let text):
                guard let content = text.contentOut else {
                    assertionFailure()
                    return
                }
                let newViewController = TermsDescriptionTextView(text: content)
                self?.router.pushViewController(viewController: newViewController)
                
            case .failed(_):
                assertionFailure("Failed move to Terms Description ")
            }
        }
    }
    
    private func goToPrivacyPolicy() {
        let newViewController = PrivacyPolicyWebView()
        router.pushViewController(viewController: newViewController)
    }
}


