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
    
    @IBOutlet weak var tableView: UITableView?
    
    var isFromSettings: Bool = false
    
    private var cellModels = [AutoSyncSettingsRowType: AutoSyncModel]()
    
    private var autoSyncSettings: AutoSyncSettings?
    
    weak var delegate: AutoSyncDataSourceDelegate?
    
    func setup(table: UITableView) {
        tableView = table
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
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
        
        cellModels.removeAll()
        setupCells(with: settings)
    }
    
    private func setupCells(with settings: AutoSyncSettings) {
        let headerModel = AutoSyncModel(title: TextConstants.autoSyncNavigationTitle, subTitle: "", type: .headerSlider, setting: settings.photoSetting, selected: settings.isAutoSyncOptionEnabled)
        let photoSettingModel = AutoSyncModel(title: TextConstants.autoSyncCellPhotos, subTitle: "", type: .photoSetting, setting: settings.photoSetting, selected: false)
        let videoSettingModel = AutoSyncModel(title: TextConstants.autoSyncCellPhotos, subTitle: "", type: .videoSetting, setting: settings.videoSetting, selected: false)
        
        cellModels = [.headerSlider : headerModel,
                      .photoSetting : photoSettingModel,
                      .videoSetting : videoSettingModel]
        
        reloadTableView()
    }
    
    func createAutoSyncSettings() -> AutoSyncSettings {
        guard let settings = autoSyncSettings else {
            return AutoSyncSettings()
        }
        return settings
    }
    
    func forceDisableAutoSync() {
        MenloworksTagsService.shared.onAutosyncStatus(isOn: false)
        MenloworksTagsService.shared.onAutosyncVideosStatusOff()
        MenloworksTagsService.shared.onAutosyncPhotosStatusOff()
        
        autoSyncSettings?.disableAutoSync()
        updateCells()
    }
    
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let shouldShowAllSettings = cellModels[.headerSlider]?.isSelected, shouldShowAllSettings {
            return cellModels.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellType = AutoSyncSettingsRowType(rawValue: indexPath.row), let model = cellModels[cellType] else {
            return UITableViewAutomaticDimension
        }
        
        return model.height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = AutoSyncSettingsRowType(rawValue: indexPath.row), let model = cellModels[rowType] else {
            return UITableViewCell()
        }
        
        if model.cellType == .headerSlider {
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
            autoSyncCell.setup(with: model)
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
    
    func collapseSettings() {
        let modelsToUnselect = cellModels.filter { $0.key != .headerSlider }
        modelsToUnselect.forEach{ $0.value.isSelected = false }
        
        reloadTableView()
    }

}

extension AutoSyncDataSource: AutoSyncSwitcherTableViewCellDelegate {
    func onValueChanged(model: AutoSyncModel) {
        cellModels[model.cellType] = model

        if model.cellType == .headerSlider {
            if model.isSelected {
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
        
        if setting.syncItemType == .photo {
            if setting.option == .wifiOnly {
                MenloworksTagsService.shared.onAutosyncPhotosViaWifi()
            } else if setting.option == .wifiAndCellular {
                MenloworksTagsService.shared.onAutosyncPhotosViaLte()
            }
        } else {
            if setting.option == .wifiOnly {
                MenloworksTagsService.shared.onAutosyncVideoViaWifi()
            } else if setting.option == .wifiAndCellular {
                MenloworksTagsService.shared.onAutosyncVideoViaLte()
            }
        }
    
        if autoSyncSettings?.photoSetting.option == .never, autoSyncSettings?.videoSetting.option == .never {
            forceDisableAutoSync()
        }
    }
    
    func shouldChangeHeight(toExpanded: Bool, cellType: AutoSyncSettingsRowType) {
        if toExpanded {
            let modelsToUnselect = cellModels.filter { !$0.key.isContained(in: [cellType, .headerSlider]) }
            modelsToUnselect.forEach{ $0.value.isSelected = false }
        }

        reloadTableView()
    }
}
