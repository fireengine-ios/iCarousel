//
//  TurkcellSecurityTurkcellSecurityViewController.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TurkcellSecurityViewController: ViewController {

    var output: TurkcellSecurityViewOutput!

    @IBOutlet weak var tableView: UITableView!
    
    let cellHeight: CGFloat = 62
    
    let turkCellSecurityPasscodeCellIndex = IndexPath(row: 0, section: 0)
    let turkCellSecurityAutologinCellIndex = IndexPath(row: 1, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib.init(nibName: CellsIdConstants.settingsTableViewSwitchCellID,
                                      bundle: nil),
                           forCellReuseIdentifier: CellsIdConstants.settingsTableViewSwitchCellID)
        tableView.delegate = self
        tableView.dataSource = self
  
        output.viewIsReady()
    }
}

// MARK: TurkcellSecurityViewInput
extension TurkcellSecurityViewController: TurkcellSecurityViewInput {
    
    func setupSecuritySettings(passcode: Bool, autoLogin: Bool) {
        guard let securityPasscodeCell = tableView.cellForRow(at: turkCellSecurityPasscodeCellIndex) as? SettingsTableViewSwitchCell,
            let securityAutoLoginCell = tableView.cellForRow(at: turkCellSecurityAutologinCellIndex) as? SettingsTableViewSwitchCell else {
                return
        }
        securityPasscodeCell.stateSwitch.setOn(passcode, animated: false)
        securityAutoLoginCell.stateSwitch.setOn(autoLogin, animated: false)
    }
    
}

// MARK: - Table Delegates
extension TurkcellSecurityViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.settingsTableViewSwitchCellID, for: indexPath) as! SettingsTableViewSwitchCell
        
        cell.actionDelegate = self
        var cellLabelText = ""
        switch indexPath.row {
        case 0:
            cellLabelText = TextConstants.settingsViewCellTurkcellPassword
        case 1:
            cellLabelText = TextConstants.settingsViewCellTurkcellAutoLogin
        default:
            break
        }
        cell.setTextForLabel(titleText: cellLabelText, needShowSeparator: true)
        cell.stateSwitch.setOn(false, animated: false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension TurkcellSecurityViewController: SettingsTableViewSwitchCellDelegate {
    func switchToggled(positionOn: Bool, cell: SettingsTableViewSwitchCell) {
        
        guard let securityPasscodeCell = tableView.cellForRow(at: turkCellSecurityPasscodeCellIndex) as? SettingsTableViewSwitchCell,
            let securityAutoLoginCell = tableView.cellForRow(at: turkCellSecurityAutologinCellIndex) as? SettingsTableViewSwitchCell else {
                return
        }
        output.securityChanged(passcode: securityPasscodeCell.stateSwitch.isOn,
                               autoLogin: securityAutoLoginCell.stateSwitch.isOn)
    }
}
