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

class AutoSyncDataSource: NSObject , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var tableHConstraint: NSLayoutConstraint?
    var isFromSettings: Bool = false
    
    var tableDataArray = [AutoSyncModel]()
    
    private var autoSyncSettings: AutoSyncSettings?
    
    weak var delegate: AutoSyncDataSourceDelegate?
    
    func configurateTable(table: UITableView, tableHConstraint: NSLayoutConstraint?){
        tableView = table
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = 44.0
        self.tableHConstraint = tableHConstraint
        
        registerCells(with: [CellsIdConstants.autoSyncSwitcherCellID,
                             CellsIdConstants.autoSyncSettingsCellID])
    }
    
    private func registerCells(with identifiers: [String]) {
        for identifier in identifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView?.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
    func showCellsFromModels(models:[AutoSyncModel]){
        tableDataArray = models
        reloadTableView()
    }
    
    func createSettingsAutoSyncModel () -> SettingsAutoSyncModel{
        let model = SettingsAutoSyncModel()
        model.isAutoSyncEnable = tableDataArray[0].isSelected
        //model.isSyncViaWifi = tableDataArray[1].isSelected
        model.mobileDataPhotos = tableDataArray[1].isSelected
        model.mobileDataVideo = tableDataArray[2].isSelected
        return model
    }
    
    func getTableH() -> CGFloat{
        let rowsCount = tableView?.numberOfRows(inSection: 0) ?? 0
        var tableH: CGFloat = 0
        for i in 0...rowsCount{
            let indexPath = IndexPath(row: i, section: 0)
            if let cellRect = tableView?.rectForRow(at: indexPath){
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
        }
        return tableDataArray.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let model = tableDataArray[indexPath.row]
//        if model.cellType == .typeSwitcher {
//            return 228.0
//        }
//        return 83.0
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableDataArray[indexPath.row]//TODO: ework enum or change it to SWITCH - case
        if model.cellType == .headerLike {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncSwitcherCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSwitcherTableViewCell
            autoSyncCell.delegate = self
            autoSyncCell.configurateCellWith(model: model)
            autoSyncCell.setColors(isFromSettings: isFromSettings)
            return autoSyncCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncSettingsCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSettingsTableViewCell
            autoSyncCell.configurate(with: AutoSyncSetting(syncItemType: .photo, option: .never))
            autoSyncCell.delegate = self
            return autoSyncCell
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

extension AutoSyncDataSource: AutoSyncSwitcherTableViewCellDelegate {
    func onValueChanged(model: AutoSyncModel, cell : AutoSyncSwitcherTableViewCell){
        let indexPath = tableView?.indexPath(for: cell)
        tableDataArray[(indexPath?.row)!] = model
        
        if model.cellType == .headerLike {
            if cell.switcher.isOn {
                delegate?.enableAutoSync()
            }
        }
    }
}


extension AutoSyncDataSource: AutoSyncSettingsTableViewCellDelegate {
    func didChange(setting: AutoSyncSetting) {
        
    }
    
    func didChangeHeight() {
        UIView.performWithoutAnimation {
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }

        if let constraint = tableHConstraint {
            constraint.constant = getTableH()
            tableView?.updateConstraints()
        }
        
    }
    
    
}
