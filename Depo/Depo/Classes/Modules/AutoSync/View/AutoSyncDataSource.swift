//
//  AutoSyncDataSource.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class AutoSyncDataSource: NSObject , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView?
    
    var tableDataArray = [AutoSyncModel]()
    
    func configurateTable(table: UITableView){
        tableView = table
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
        
        let nib1 = UINib(nibName: AutoSyncSwitcherTableViewCell.reUseID(), bundle: nil)
        tableView?.register(nib1, forCellReuseIdentifier: AutoSyncSwitcherTableViewCell.reUseID())
        
        let nib2 = UINib(nibName: AutoSyncInformTableViewCell.reUseID(), bundle: nil)
        tableView?.register(nib2, forCellReuseIdentifier: AutoSyncInformTableViewCell.reUseID())
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
            let cell = tableView.dequeueReusableCell(withIdentifier: AutoSyncSwitcherTableViewCell.reUseID(), for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSwitcherTableViewCell
            autoSyncCell.configurateCellWith(model: model)
            return autoSyncCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: AutoSyncInformTableViewCell.reUseID(), for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncInformTableViewCell
            autoSyncCell.configurateCellWith(model: model)
            return cell
        }
        
    }
    
}
