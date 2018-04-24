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


class AutoSyncDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    private let estimatedRowHeight: CGFloat = 260.0
    
    @IBOutlet weak var tableView: UITableView?
    
    var isFromSettings: Bool = false
    
    var tableDataArray = [AutoSyncModel]()
    
    private var autoSyncSettings: AutoSyncSettings?
    
    weak var delegate: AutoSyncDataSourceDelegate?
    
    func setup(table: UITableView) {
        tableView = table
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = estimatedRowHeight
        tableView?.separatorStyle = .none
        
        registerCells(with: [CellsIdConstants.autoSyncSwitcherCellID,
                             CellsIdConstants.autoSyncSettingsCellID])
    }
    
    private func registerCells(with identifiers: [String]) {
        for identifier in identifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView?.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
    func showCells(from settings: AutoSyncSettings) {
        autoSyncSettings = settings
        setupCells(with: settings)
    }
    
    private func updateCells() {
        guard let settings = autoSyncSettings else {
            return
        }
        
        tableDataArray.removeAll()
        setupCells(with: settings)
    }
    
    private func setupCells(with settings: AutoSyncSettings) {
        let headerModel = AutoSyncModel(title: TextConstants.autoSyncNavigationTitle, subTitle: "", type: .headerLike, setting: settings.photoSetting, selected: settings.isAutoSyncOptionEnabled)
        let photoSettingModel = AutoSyncModel(title: TextConstants.autoSyncCellPhotos, subTitle: "", type: .typeSwitcher, setting: settings.photoSetting, selected: false)
        let videoSettingModel = AutoSyncModel(title: TextConstants.autoSyncCellPhotos, subTitle: "", type: .typeSwitcher, setting: settings.videoSetting, selected: false)
        tableDataArray.append(contentsOf: [headerModel, photoSettingModel, videoSettingModel])
        reloadTableView()
    }
    
    func createAutoSyncSettings() -> AutoSyncSettings {
        guard let settings = autoSyncSettings else {
            return AutoSyncSettings()
        }
        return settings
    }
    
    func forceDisableAutoSync() {
        autoSyncSettings?.disableAutoSync()
        updateCells()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableDataArray[indexPath.row]//TODO: ework enum or change it to SWITCH - case
        if model.cellType == .headerLike {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncSwitcherCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSwitcherTableViewCell
            autoSyncCell.delegate = self
            if let syncSetting = model.syncSetting {
                autoSyncCell.setup(with: model, setting: syncSetting)
            }
            autoSyncCell.setColors(isFromSettings: isFromSettings)
            return autoSyncCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.autoSyncSettingsCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! AutoSyncSettingsTableViewCell
            if let syncSetting = model.syncSetting {
                autoSyncCell.setup(with: syncSetting)
            }
            autoSyncCell.setColors(isFromSettings: isFromSettings)
            autoSyncCell.delegate = self
            return autoSyncCell
        }
        
    }

    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

}

extension AutoSyncDataSource: AutoSyncSwitcherTableViewCellDelegate {
    func onValueChanged(model: AutoSyncModel, cell: AutoSyncSwitcherTableViewCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else {
            return
        }
        
        tableDataArray[indexPath.row] = model

        if model.cellType == .headerLike {
            if cell.switcher.isOn {
                autoSyncSettings?.isAutoSyncOptionEnabled = true
                delegate?.enableAutoSync()
            } else {
                forceDisableAutoSync()
                reloadTableView()
            }
        }
    }
}


extension AutoSyncDataSource: AutoSyncSettingsTableViewCellDelegate {
    func didChange(setting: AutoSyncSetting) {
        autoSyncSettings?.set(setting: setting)
        if autoSyncSettings?.photoSetting.option == .never, autoSyncSettings?.videoSetting.option == .never {
            forceDisableAutoSync()
        }
    }
    
    func didChangeHeight() {
        UIView.performWithoutAnimation {
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }
    }
}
