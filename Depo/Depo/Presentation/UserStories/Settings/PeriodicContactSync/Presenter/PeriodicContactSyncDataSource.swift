//
//  PeriodicContactSyncDataSource.swift
//  Depo
//
//  Created by Brothers Harhun on 18.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol PeriodicContactSyncDataSourceDelegate {
    func onValueChanged()
}

final class PeriodicContactSyncDataSource: NSObject {
    private let estimatedRowHeight: CGFloat = 260.0
    
    @IBOutlet private weak var tableView: UITableView?
    
    private var timeSettingModel: PeriodContactsSyncModel?
    
    private var periodContactsSyncSettings: PeriodicContactsSyncSettings?
    
    var delegate: PeriodicContactSyncDataSourceDelegate?
        
    func setup(table: UITableView) {
        tableView = table
        tableView?.dataSource = self
        tableView?.backgroundColor = UIColor.clear
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.estimatedRowHeight = estimatedRowHeight
        tableView?.separatorStyle = .none
        
        registerCells(with: [CellsIdConstants.periodicContactSyncSettingsCellID])
    }
    
    private func registerCells(with identifiers: [String]) {
        for identifier in identifiers {
            let nib = UINib(nibName: identifier, bundle: nil)
            tableView?.register(nib, forCellReuseIdentifier: identifier)
        }
    }
    
    func showCells(from settings: PeriodicContactsSyncSettings) {
        periodContactsSyncSettings = settings
        setupCells(with: settings)
    }
    
    private func updateCells() {
        guard let settings = periodContactsSyncSettings else {
            return
        }
        
        timeSettingModel = nil
        setupCells(with: settings)
    }
    
    private func setupCells(with settings: PeriodicContactsSyncSettings) {
        timeSettingModel = PeriodContactsSyncModel(title: TextConstants.autoSyncCellAutoSync, setting: settings.timeSetting, selected: settings.isPeriodicContactsSyncOptionEnabled)
        reloadTableView()
    }
    
    func createAutoSyncSettings() -> PeriodicContactsSyncSettings {
        guard let settings = periodContactsSyncSettings else {
            return PeriodicContactsSyncSettings()
        }
        return settings
    }
    
    func forceDisableAutoSync() {
        periodContactsSyncSettings?.disablePeriodicContactsSync()
        updateCells()
    }
    
     func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
}

// MARK: - PeriodicContactSyncSettingsTableViewCellDelegate

extension PeriodicContactSyncDataSource: PeriodicContactSyncSettingsTableViewCellDelegate {
    
    func onValueChanged(cell: PeriodicContactSyncSettingsTableViewCell) {
        if cell.switcher.isOn {
            periodContactsSyncSettings?.isPeriodicContactsSyncOptionEnabled = true
        } else {
            forceDisableAutoSync()
            reloadTableView()
        }
        
        delegate?.onValueChanged()
    }
    
    func didChangeTime(setting: PeriodicContactsSyncSetting) {
        periodContactsSyncSettings?.set(periodicContactsSync: setting)
        
        delegate?.onValueChanged()
    }
    
}

// MARK: - UITableViewDataSource

extension PeriodicContactSyncDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.periodicContactSyncSettingsCellID, for: indexPath)
        cell.selectionStyle = .none
        let autoSyncCell = cell as! PeriodicContactSyncSettingsTableViewCell
        autoSyncCell.delegate = self
        if let timeSettingModel = timeSettingModel,
            let syncSetting = timeSettingModel.syncSetting {
            autoSyncCell.setup(with: timeSettingModel, setting: syncSetting)
        }
        return autoSyncCell
    }
    
}
