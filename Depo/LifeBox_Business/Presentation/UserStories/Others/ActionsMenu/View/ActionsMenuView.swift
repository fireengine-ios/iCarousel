//
//  ActionsMenuActionsMenuViewController.swift
//  Depo
//
//  Created by Oleg on 17/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ActionsMenuView: UIView, ActionsMenuViewInput, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var tableDataMArray = [ActionMenyItem]()
    
    // MARK: Life cycle
    class func initFromXib() -> ActionsMenuView {
        let view = UINib(nibName: "ActionsMenuView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ActionsMenuView
        view.configurateView()
        return view
    }
    
    func configurateView() {
        tableView.isScrollEnabled = false
        
        let nib = UINib.init(nibName: CellsIdConstants.actionsMenuCellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.actionsMenuCellID)
    }

    // MARK: ActionsMenuViewInput
    
    func showActions(actions: [ActionMenyItem]) {
        tableDataMArray.removeAll()
        tableDataMArray.append(contentsOf: actions)
        tableView.reloadData()
    }
    
    func heightForCell() -> CGFloat {
        if (Device.isIpad) {
            return 59.0
        }
        return 65.0
    }
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataMArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForCell()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.actionsMenuCellID, for: indexPath)
        cell.selectionStyle = .none
        guard let menuCell = cell as? ActionsMenuTableViewCell else {
            return cell
        }
        let actin = tableDataMArray[indexPath.row]
        menuCell.titleLabel.text = actin.name
        return menuCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actin = tableDataMArray[indexPath.row]
        actin.action()
    }
    
}
