//
//  AutoSyncDataSource.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncDataSource: NSObject , UITableViewDelegate, UITableViewDataSource, AutoSyncSwitcherTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView?
    
    var tableDataArray = [AutoSyncModel]()
    
    func configurateTable(table: UITableView){
        tableView = table
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
        
        let nib1 = UINib(nibName: CellsIdConstants.autoSyncSwitcherCellID, bundle: nil)
        tableView?.register(nib1, forCellReuseIdentifier: CellsIdConstants.autoSyncSwitcherCellID)
        
        let nib2 = UINib(nibName: CellsIdConstants.autoSyncInformCellID, bundle: nil)
        tableView?.register(nib2, forCellReuseIdentifier: CellsIdConstants.autoSyncInformCellID)
    }
    
    func showCellsFromModels(models:[AutoSyncModel]){
        tableDataArray = models
        tableView?.reloadData()
    }
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableDataArray[indexPath.row]
        if (model.cellType == .typeSwitcher){
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncSwitcherCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSwitcherTableViewCell
            autoSyncCell.delegate = self
            autoSyncCell.configurateCellWith(model: model)
            return autoSyncCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncInformCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncInformTableViewCell
            autoSyncCell.configurateCellWith(model: model)
            return cell
        }
        
    }
    
    // MARK: AutoSyncSwitcherTableViewCellDelegate
    
    func onValueChanged(model: AutoSyncModel, cell : AutoSyncSwitcherTableViewCell){
        let indexPath = tableView?.indexPath(for: cell)
        tableDataArray[(indexPath?.row)!] = model
    }
    
}
