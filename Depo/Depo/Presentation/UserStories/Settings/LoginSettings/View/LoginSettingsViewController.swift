//
//  LoginSettingsViewController.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class LoginSettingsViewController: ViewController {
    
    @IBOutlet private weak var tableView: UITableView!

    var output: LoginSettingsViewOutput!
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setup()
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: TextConstants.settingsViewCellLoginSettings)
        navigationBarWithGradientStyle()
    }
    
    //MARK: Utility Methods
    private func setup() {
        let nib = UINib(nibName: CellsIdConstants.settingsTableViewSwitchCellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.settingsTableViewSwitchCellID)
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 600
        
        tableView.reloadData()
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
    }
    
}

// MARK: - UITableViewDataSource
extension LoginSettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.cellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.settingsTableViewSwitchCellID,
                                                         for: indexPath) as? SettingsTableViewSwitchCell
        
        ///setup here instead of willDisplayCell because of estimatedRowHeight
        if let type = output.cellTypes[safe: indexPath.row], let params = output.cellsData.first(where: { $0.key == type }) {
            settingsCell?.setup(params: params, delegate: self)
        }
        
        return settingsCell ?? UITableViewCell()
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
