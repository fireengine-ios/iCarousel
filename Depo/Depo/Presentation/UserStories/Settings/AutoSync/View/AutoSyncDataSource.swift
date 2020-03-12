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
    func didChangeSettingsOption(settings: AutoSyncSetting)
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
        
        tableView?.register(nibCell: AutoSyncSwitcherTableViewCell.self)
        tableView?.register(nibCell: AutoSyncSettingsTableViewCell.self)
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
        let videoSettingModel = AutoSyncModel(title: TextConstants.autoSyncCellVideos, subTitle: "", type: .videoSetting, setting: settings.videoSetting, selected: false)
        
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
            let cell = tableView.dequeue(reusable: AutoSyncSwitcherTableViewCell.self, for: indexPath)
            cell.delegate = self
            if let syncSetting = model.syncSetting {
                cell.setup(with: model, setting: syncSetting)
            }
            return cell
        } else {
            let cell = tableView.dequeue(reusable: AutoSyncSettingsTableViewCell.self, for: indexPath)
            cell.setup(with: model)
            cell.delegate = self
            return cell
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
        
        if autoSyncSettings?.photoSetting.option == .never, autoSyncSettings?.videoSetting.option == .never {
            forceDisableAutoSync()
        }
      
        delegate?.didChangeSettingsOption(settings: setting)
    }
    
    func shouldChangeHeight(toExpanded: Bool, cellType: AutoSyncSettingsRowType) {
        if toExpanded {
            let modelsToUnselect = cellModels.filter { !$0.key.isContained(in: [cellType, .headerSlider]) }
            modelsToUnselect.forEach{ $0.value.isSelected = false }
        }

        reloadTableView()
    }
}
