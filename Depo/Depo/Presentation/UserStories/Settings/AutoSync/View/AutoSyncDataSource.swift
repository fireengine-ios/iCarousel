//
//  AutoSyncDataSource.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol AutoSyncDataSourceDelegate: class {
    func enableAutoSync()
    func mobileDataEnabledFor(model: AutoSyncModel)
}

class AutoSyncDataSource: NSObject, UITableViewDelegate, UITableViewDataSource, AutoSyncSwitcherTableViewCellDelegate, AutoSyncInformTableViewCellCheckBoxStateProtocol {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var tableHConstraint: NSLayoutConstraint?
    var isFromSettings: Bool = false
    
    var tableDataArray = [AutoSyncModel]()
    
    weak var delegate: AutoSyncDataSourceDelegate?
    
    func configurateTable(table: UITableView, tableHConstraint: NSLayoutConstraint?) {
        tableView = table
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
        self.tableHConstraint = tableHConstraint
        
        let nib1 = UINib(nibName: CellsIdConstants.autoSyncSwitcherCellID, bundle: nil)
        tableView?.register(nib1, forCellReuseIdentifier: CellsIdConstants.autoSyncSwitcherCellID)
        
        let nib2 = UINib(nibName: CellsIdConstants.autoSyncInformCellID, bundle: nil)
        tableView?.register(nib2, forCellReuseIdentifier: CellsIdConstants.autoSyncInformCellID)
    }
    
    func showCellsFromModels(models: [AutoSyncModel]) {
        tableDataArray = models
        tableView?.reloadData()
        if let constraint = tableHConstraint {
            constraint.constant = getTableH()
            tableView?.updateConstraints()
        }
    }
    
    func createSettingsAutoSyncModel () -> SettingsAutoSyncModel {
        let model = SettingsAutoSyncModel()
        model.isAutoSyncEnable = tableDataArray[0].isSelected
        //model.isSyncViaWifi = tableDataArray[1].isSelected
        model.mobileDataPhotos = tableDataArray[3].isSelected
        model.mobileDataVideo = tableDataArray[4].isSelected
        return model
    }
    
    func getTableH() -> CGFloat {
        let rowsCount = tableView?.numberOfRows(inSection: 0) ?? 0
        var tableH: CGFloat = 0
        for i in 0...rowsCount {
            let indexPath = IndexPath(row: i, section: 0)
            if let cellRect = tableView?.rectForRow(at: indexPath) {
                tableH = tableH + cellRect.size.height
            }
        }
        
        return tableH
    }
    
    func forceDisableAutoSync() {
        for index in 0..<tableDataArray.count {
            let model = tableDataArray[index]
            if (model.cellType == .headerLike) {
                if let cell = tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as? AutoSyncSwitcherTableViewCell {
                    cell.switcher.isOn = false
                }
                break
            }
        }
    }
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //FIXME: make it more bandable
        if let model = tableDataArray.first, model.cellType == .headerLike, model.isSelected == false {
            return 1
        } else {
            for model in tableDataArray {
                 if model.cellType == .typeSwitherActivator, model.isSelected == false {
                    return 3
                }
            }
        }
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = tableDataArray[indexPath.row]
        if (model.cellType == .typeSwitcher) {
            return 50
        }
        return 83.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableDataArray[indexPath.row]//TODO: ework enum or change it to SWITCH - case
        if (model.cellType == .typeSwitcher) || model.cellType == .headerLike {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncSwitcherCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSwitcherTableViewCell
            autoSyncCell.delegate = self
            autoSyncCell.configurateCellWith(model: model)
            autoSyncCell.setColors(isFromSettings: isFromSettings)
            return autoSyncCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncInformCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncInformTableViewCell
            autoSyncCell.stateDelegate = self
            autoSyncCell.configurateCellWith(model: model)
            autoSyncCell.setColors(isFromSettings: isFromSettings)
            return cell
        }
        
    }
    
    // MARK: AutoSyncSwitcherTableViewCellDelegate
    
    func onValueChanged(model: AutoSyncModel, cell: AutoSyncSwitcherTableViewCell) {
        let indexPath = tableView?.indexPath(for: cell)
        tableDataArray[(indexPath?.row)!] = model
        
        if model.cellType == .headerLike {
            if cell.switcher.isOn {
                delegate?.enableAutoSync()
            } else {
                reloadTableView()
            }
        }
        if model.cellType == .typeSwitcher, model.isSelected {
            delegate?.mobileDataEnabledFor(model: model)
        }
    }
    
    func checkBoxChangedState(state: Bool, model: AutoSyncModel, cell: AutoSyncInformTableViewCell) {
        let indexPath = tableView?.indexPath(for: cell)
        tableDataArray[(indexPath?.row)!] = model
        
        if model.cellType == .typeSwitherActivator {
            tableView?.reloadData()
            cell.separatorView.isHidden = state
        }
    }
    
    func reloadTableView() {
        tableView?.reloadData()
        if let constraint = tableHConstraint {
            constraint.constant = getTableH()
            tableView?.updateConstraints()
        }
    }
    
}
