//
//  TermsAndPolicyViewController.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class TermsAndPolicyViewController: BaseViewController {
    
    var output: TermsAndPolicyViewOutput!
    typealias NameOfListItem = String

    @IBOutlet weak var tableView: UITableView!
    private var listOfItems: [NameOfListItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setTitle(withString: TextConstants.settingsViewCellPrivacyAndTerms)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillBecomeActive()
    }
    
    private func setupTableView() {
        let nib = UINib.init(nibName: CellsIdConstants.settingTableViewCellID,
                             bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.settingTableViewCellID)
        tableView.backgroundColor = UIColor.clear
    }
}

extension TermsAndPolicyViewController: TermsAndPolicyViewInput {
    
    func showCellsData(array: [String]) {
        listOfItems.removeAll()
        listOfItems.append(contentsOf: array)
        tableView.reloadData()
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
            output.didPressTermsCell()
        case 1:
            output.didPressPolicyCell()
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
