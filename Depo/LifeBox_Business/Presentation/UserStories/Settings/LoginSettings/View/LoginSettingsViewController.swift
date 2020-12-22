//
//  LoginSettingsViewController.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class LoginSettingsViewController: ViewController {
    
    @IBOutlet private weak var tableView: UITableView!  {
        willSet {
            newValue.register(nibCell: SettingsTableViewSwitchCell.self)
            newValue.dataSource = self
            
            newValue.rowHeight = UITableViewAutomaticDimension
            newValue.estimatedRowHeight = 160
            
            newValue.isHidden = true
        }
    }
    
    var output: LoginSettingsViewOutput!
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: TextConstants.settingsViewCellLoginSettings)
        navigationBarWithGradientStyle()
    }
}

// MARK: - LoginSettingsViewInput
extension LoginSettingsViewController: LoginSettingsViewInput {
    func updateTableView() {
        if let visibleCellIndexPaths = tableView.indexPathsForVisibleRows {
            tableView.beginUpdates()
            tableView.reloadRows(at: visibleCellIndexPaths, with: .none)
            tableView.endUpdates()
        }
        
        tableView.isHidden = false
    }
    
}

// MARK: - UITableViewDataSource
extension LoginSettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = tableView.dequeue(reusable: SettingsTableViewSwitchCell.self,
                                             for: indexPath)
        
        ///setup here instead of willDisplayCell because of estimatedRowHeight
        if let type = output.cellTypes[safe: indexPath.row], let params = output.cellsData.first(where: { $0.key == type }) {
            settingsCell.setup(params: params, delegate: self)
        }
        
        return settingsCell
    }
}

// MARK: - SettingsTableViewSwitchCellDelegate
extension LoginSettingsViewController: SettingsTableViewSwitchCellDelegate {
    func switchToggled(cell: SettingsTableViewSwitchCell) {
        guard let type = cell.type else {
            assertionFailure("cell's type is missing")
            return
        }
        output.updateStatus(type: type, isOn: cell.toggle)
    }
}
