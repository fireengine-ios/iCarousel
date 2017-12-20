//
//  TurkcellSecurityTurkcellSecurityViewController.swift
//  Depo
//
//  Created by AlexanderP on 19/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TurkcellSecurityViewController: UIViewController {

    var output: TurkcellSecurityViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
    
//    if indexPath == turkCellSecurityPasscodeCellIndex {
//    
//    let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.settingsTableViewSwitchCellID, for: indexPath) as! SettingsTableViewSwitchCell
//    cell.actionDelegate = self
//    cell.setTextForLabel(titleText: array[indexPath.row], needShowSeparator: indexPath.row != array.count - 1)
//    cell.stateSwitch.setOn(turkCellSeuritySettingsPassState ?? false, animated: false)
//    return cell
//    } else if indexPath == turkCellSecurityAutologinCellIndex {
//    
//    let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.settingsTableViewSwitchCellID, for: indexPath) as! SettingsTableViewSwitchCell
//    cell.actionDelegate = self
//    cell.setTextForLabel(titleText: array[indexPath.row], needShowSeparator: indexPath.row != array.count - 1)
//    cell.stateSwitch.setOn(turkCellSeuritySettingsAutoLoginState ?? false, animated: false)
//    return cell
//    } else {
}

// MARK: TurkcellSecurityViewInput
extension TurkcellSecurityViewController: TurkcellSecurityViewInput {

}
