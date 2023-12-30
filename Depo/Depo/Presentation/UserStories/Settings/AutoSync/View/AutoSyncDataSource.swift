//
//  AutoSyncSettingsDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 3/6/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol AutoSyncDataSourceDelegate: AnyObject {
    func checkForEnableAutoSync()
    func didChangeSettingsOption(settings: AutoSyncSetting)
}

final class AutoSyncDataSource: NSObject {
    
    private let tableView: UITableView
    private weak var delegate: AutoSyncDataSourceDelegate?
    
    private var models = [AutoSyncModel]()
    private var albumModels = [AutoSyncAlbumModel]()
    private var selectedAlbums = [AutoSyncAlbum]()
    private(set) var autoSyncSetting = AutoSyncSettings()
    
    private var timeSettingModel: PeriodContactsSyncModel?
    private var periodContactsSyncSettings: PeriodicContactsSyncSettings?
    weak var delegateContact: PeriodicContactSyncDataSourceDelegate?
    
    var autoSyncAlbums: [AutoSyncAlbum] {
        return albumModels.map { $0.album }
    }
    
    var isFromSettings = false
    private var syncModel = AutoSyncModel(type: .header)
    
    private let tableViewAnimationType = UITableView.RowAnimation.top
    
    //MARK: - Init
    
    init(tableView: UITableView, delegate: AutoSyncDataSourceDelegate?, delegateContact: PeriodicContactSyncDataSourceDelegate?) {
        self.tableView = tableView
        self.delegate = delegate
        self.delegateContact = delegateContact
        super.init()
        
        setupTableView()
        setupDefaultState()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        tableView.addRoundedShadows(cornerRadius: 16,
                                    shadowColor: AppColor.viewShadowLight.cgColor,
                                    opacity: 0.8, radius: 6.0)
        tableView.backgroundColor = .clear
        
        
        AutoSyncRowType.cellTypes.forEach { tableView.register(nibCell: $0.self) }
        
        // Register Contact
        let identifier = CellsIdConstants.periodicContactSyncSettingsCellID
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)

        
//        //need for correct hide animation bottom cells
//        let footer = UIView(frame: CGRect(x: 0, y: 0, width: Device.winSize.width, height: 150))
//        footer.backgroundColor = AppColor.primaryBackground.color
//        let line = UIView(frame: CGRect(x: 16, y: 0, width: Device.winSize.width - 32, height: 1))
//        line.backgroundColor = AppColor.itemSeperator.color
//        footer.addSubview(line)
//        footer.isUserInteractionEnabled = false
//        tableView.tableFooterView = footer
        
        let back = UIView(frame: tableView.bounds)
        tableView.backgroundView = back
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(collapseCells))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        back.addGestureRecognizer(recognizer)
    }
    
    private func setupDefaultState() {
        models = [AutoSyncHeaderModel(type: .autosync, setting: nil, isSelected: true),
                  AutoSyncHeaderModel(type: .albums, setting: nil, isSelected: false)]
        tableView.reloadData()
    }
    
    func setupModels(with settings: AutoSyncSettings, albums: [AutoSyncAlbum]) {
        autoSyncSetting = settings
        
        selectedAlbums = albums.filter { $0.isSelected }
        albumModels = albums.map { album -> AutoSyncAlbumModel in
            let model = AutoSyncAlbumModel(album: album)
            model.isEnabled = autoSyncSetting.isAutoSyncOptionEnabled
            if model.album.isMainAlbum {
                model.isAllChecked = selectedAlbums.count == albums.count
            }
            return model
        }
        
        if isFromSettings {
            if autoSyncSetting.isAutoSyncOptionEnabled {
                enableAutoSync()
            } else {
                forceDisableAutoSync()
            }
        } else {
            if autoSyncSetting.isAutoSyncOptionEnabled {
                enableAutoSync()
            } else {
                showHideAutosyncSettings(isShow: true)
            }
        }
        
    }
    
    func checkPermissionsSuccessed() {
        enableAutoSync()
    }
    
    func forceDisableAutoSync() {
        autoSyncSetting.isAutoSyncOptionEnabled = false
        models = [AutoSyncHeaderModel(type: .autosync, setting: nil, isSelected: false),
                  AutoSyncHeaderModel(type: .albums, setting: nil, isSelected: false)]
        tableView.reloadData()
    }
    
    func showCells(from settings: PeriodicContactsSyncSettings) {
        periodContactsSyncSettings = settings
        setupCellsContact(with: settings)
    }
    
    private func updateCellsContact() {
        guard let settings = periodContactsSyncSettings else {
            return
        }
        
        timeSettingModel = nil
        setupCellsContact(with: settings)
    }
    
    private func setupCellsContact(with settings: PeriodicContactsSyncSettings) {
        timeSettingModel = PeriodContactsSyncModel(title: TextConstants.autoSyncCellAutoSync, setting: settings.timeSetting, selected: settings.isPeriodicContactsSyncOptionEnabled)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func createAutoSyncSettings() -> PeriodicContactsSyncSettings {
        guard let settings = periodContactsSyncSettings else {
            return PeriodicContactsSyncSettings()
        }
        return settings
    }
    
    func forceDisableAutoSyncContact() {
        periodContactsSyncSettings?.disablePeriodicContactsSync()
        updateCellsContact()
    }
}

//MARK: - UITableViewDataSource

extension AutoSyncDataSource: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 16
        } else {
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return models.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle: String = self.tableView(tableView, titleForHeaderInSection: section) else { return nil }
        let title: InsetsLabel = InsetsLabel()
        title.text = sectionTitle
        title.textColor = AppColor.syncHeader.color
        title.font = .appFont(.medium, size: 14)
        title.insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return title
      }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return TextConstants.periodContactSyncFromSettingsTitle
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let model = models[indexPath.row]
            
            guard let cell = tableView.dequeue(reusable: model.type.cellClass().self, for: indexPath) as? AutoSyncTableViewCell else {
                assertionFailure()
                return UITableViewCell()
            }

            if ((cell as? AutoSyncSwitcherTableViewCell) != nil) {
                if let autoSyncSwitchCell = cell as? AutoSyncSwitcherTableViewCell {
                    autoSyncSwitchCell.isFromSetting = isFromSettings
                }
            }
            
            cell.selectionStyle = .none
            cell.setup(with: model, delegate: self)
            cell.backgroundColor = AppColor.secondaryBackground.color
            return cell
        } else {
            // Contact
            let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.periodicContactSyncSettingsCellID, for: indexPath)
            cell.selectionStyle = .none
            let autoSyncCell = cell as! PeriodicContactSyncSettingsTableViewCell
            autoSyncCell.delegate = self
            if let timeSettingModel = timeSettingModel,
                let syncSetting = timeSettingModel.syncSetting {
                autoSyncCell.setup(with: timeSettingModel, setting: syncSetting)
            }
            autoSyncCell.backgroundColor = AppColor.secondaryBackground.color
            
            
            return autoSyncCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = 16
        var corners: UIRectCorner = []
        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1  {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AutoSyncTableViewCell {
            cell.didSelect()
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

// MARK: - PeriodicContactSyncSettingsTableViewCellDelegate

extension AutoSyncDataSource: PeriodicContactSyncSettingsTableViewCellDelegate {
    func onValueChanged(cell: PeriodicContactSyncSettingsTableViewCell) {
        if cell.switcher.isOn {
            periodContactsSyncSettings?.isPeriodicContactsSyncOptionEnabled = true
            periodContactsSyncSettings?.timeSetting.option = .daily
            updateCellsContact()
        } else {
            forceDisableAutoSyncContact()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        delegateContact?.onValueChanged()
    }
    
    func didChangeTime(setting: PeriodicContactsSyncSetting) {
        periodContactsSyncSettings?.set(periodicContactsSync: setting)
        
        delegateContact?.onValueChanged()
    }
}

//MARK: - AutoSyncSettingsTableViewCellDelegate

extension AutoSyncDataSource: AutoSyncSettingsTableViewCellDelegate {
    func didChange(setting: AutoSyncSetting) {
        delegate?.didChangeSettingsOption(settings: setting)
        
        let headerType: AutoSyncHeaderType
        switch setting.syncItemType {
        case .photo:
            headerType = .photo
            autoSyncSetting.photoSetting = setting
        case .video:
            headerType = .video
            autoSyncSetting.videoSetting = setting
        }
        
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == headerType }) else {
            return
        }
        
        (models[index] as? AutoSyncHeaderModel)?.setting = setting
        
        let indexPath = IndexPath(row: index, section: 0)
        updateTableView({
            tableView.reloadRows(at: [indexPath], with: .none)
        }, completion: nil)
    }
    
    func setSyncOperationForAutoSyncSwither() {
        if let model = syncModel as? AutoSyncHeaderModel {
            switch model.headerType {
            case .autosync:
                if model.isSelected {
                    delegate?.checkForEnableAutoSync()
                } else {
                    disableAutoSync()
                }
            case .photo:
                if model.isSelected {
                    showSettings(type: .photo)
                } else {
                    hideSettings(type: .photo)
                }
            case .video:
                if model.isSelected {
                    showSettings(type: .video)
                } else {
                    hideSettings(type: .video)
                }
            case .albums:
                if model.isSelected {
                    showAlbums()
                    tableView.reloadData()
                } else {
                    hideAlbums()
                    tableView.reloadData()
                }
            }
        } else if let model = syncModel as? AutoSyncAlbumModel {
            if model.album.isMainAlbum {
                updateAlbums(isSelected: model.isAllChecked)
            } else {
                if model.album.isSelected {
                    selectedAlbums.append(model.album)
                } else {
                    selectedAlbums.remove(model.album)
                }
                updateMainAlbumCell()
            }
        }
    }
}

//MARK: - AutoSyncCellDelegate

extension AutoSyncDataSource: AutoSyncCellDelegate {
    func didChangeSyncMethod(model: AutoSyncModel, fromAfterLogin: Bool) {
        guard let index = models.firstIndex(where: { $0 == model }) else {
            return
        }
        syncModel = model
        models[index] = model
        
        if fromAfterLogin {
            return
        }
        if let model = model as? AutoSyncHeaderModel {
            if model.headerType == .autosync {
                if model.isSelected {
                    showHideAutosyncSettings(isShow: true)
                } else {
                    showHideAutosyncSettings(isShow: false)
                }
            }
        }
    }
    
    func didChange(model: AutoSyncModel) {
        guard let index = models.firstIndex(where: { $0 == model }) else {
            return
        }
        
        models[index] = model
        
        if let model = model as? AutoSyncHeaderModel {
            switch model.headerType {
            case .autosync:
                if model.isSelected {
                    delegate?.checkForEnableAutoSync()
                } else {
                    disableAutoSync()
                }
            case .photo:
                if model.isSelected {
                    showSettings(type: .photo)
                } else {
                    hideSettings(type: .photo)
                }
            case .video:
                if model.isSelected {
                    showSettings(type: .video)
                } else {
                    hideSettings(type: .video)
                }
            case .albums:
                if model.isSelected {
                    showAlbums()
                    tableView.reloadData()
                } else {
                    hideAlbums()
                    tableView.reloadData()
                }
            }
        } else if let model = model as? AutoSyncAlbumModel {
            if model.album.isMainAlbum {
                updateAlbums(isSelected: model.isAllChecked)
            } else {
                if model.album.isSelected {
                    selectedAlbums.append(model.album)
                } else {
                    selectedAlbums.remove(model.album)
                }
                updateMainAlbumCell()
            }
        }
    }
}

//MARK: - Change states processing

extension AutoSyncDataSource {
    
    private func enableAutoSync() {
        autoSyncSetting.isAutoSyncOptionEnabled = true
        
        guard models.first(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .photo }) == nil else {
            return
        }
        
        let settingModels = [AutoSyncHeaderModel(type: .photo, setting: autoSyncSetting.photoSetting, isSelected: false),
                             AutoSyncHeaderModel(type: .video, setting: autoSyncSetting.videoSetting, isSelected: false)]
        
        models.insert(contentsOf: settingModels, at: 1)
        let indexPaths = (1...settingModels.count).map { IndexPath(row: $0, section: 0) }
        
        updateTableView({
            tableView.insertRows(at: indexPaths, with: tableViewAnimationType)
        }, completion: { [weak self] in
            self?.updateAlbums(isSelected: nil)
        })
    }
    
    private func disableAutoSync() {
        autoSyncSetting.isAutoSyncOptionEnabled = false
        
        guard models.first(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .photo }) != nil else {
            return
        }
        
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .albums }) else {
            return
        }
        
        let indexPaths = (1...index-1).reversed().map { i -> IndexPath in
            models.remove(at: i)
            return IndexPath(row: i, section: 0)
        }
    
        updateTableView({
            tableView.deleteRows(at: indexPaths, with: tableViewAnimationType)
        }, completion: { [weak self] in
            self?.updateAlbums(isSelected: nil)
        })
    }
    
    private func showSettings(type: AutoSyncItemType) {
        let headerType: AutoSyncHeaderType = type == .photo ? .photo : .video
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == headerType }) else {
            return
        }
        
        let settingModel: AutoSyncSettingModel
        switch type {
        case .photo:
            settingModel = AutoSyncSettingModel(type: .settings, setting: autoSyncSetting.photoSetting)
        case .video:
            settingModel = AutoSyncSettingModel(type: .settings, setting: autoSyncSetting.videoSetting)
        }
        
        models.insert(settingModel, at: index + 1)
        
        updateTableView({
            tableView.insertRows(at: [IndexPath(row: index + 1, section: 0)], with: tableViewAnimationType)
        }, completion: nil)
    }
    
    private func hideSettings(type: AutoSyncItemType) {
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncSettingModel)?.setting?.syncItemType == type }) else {
            return
        }
        
        models.remove(at: index)
        
        updateTableView({
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: tableViewAnimationType)
        }, completion: nil)
    }
    
    private func showAlbums() {
        guard !albumModels.isEmpty else {
            return
        }
        
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .albums }) else {
            return
        }
        
        models.append(contentsOf: albumModels)
        
        let indexPaths = (index+1...models.count-1).map { IndexPath(row: $0, section: 0)}
        

        
        updateTableView({
            tableView.insertRows(at: indexPaths, with: tableViewAnimationType)
        }, completion: nil)
    }
    
    private func hideAlbums() {
        guard models.first(where: { $0 is AutoSyncAlbumModel }) != nil else {
            return
        }
        
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .albums }) else {
            return
        }
        
        let indexPaths = (index+1...models.count-1).reversed().map { i -> IndexPath in
            models.remove(at: i)
            return IndexPath(row: i, section: 0)
        }
        
//        updateTableView({
//            tableView.deleteRows(at: indexPaths, with: tableViewAnimationType)
//        }, completion: nil)
    }
    
    private func updateAlbums(isSelected: Bool?) {
        albumModels.forEach { model in
            model.isEnabled = autoSyncSetting.isAutoSyncOptionEnabled
            if let isSelected = isSelected, !model.album.isMainAlbum {
                model.album.isSelected = isSelected
            }
        }
        
        models.forEach { model in
            guard let model = model as? AutoSyncAlbumModel else {
                return
            }
            
            model.isEnabled = autoSyncSetting.isAutoSyncOptionEnabled
            if let isSelected = isSelected, !model.album.isMainAlbum {
                model.album.isSelected = isSelected
            }
        }
        
        if let isSelected = isSelected {
            if isSelected {
                selectedAlbums = albumModels.map { $0.album }
            } else {
                selectedAlbums = selectedAlbums.filter { $0.isMainAlbum }
            }
        }
         
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    private func updateMainAlbumCell() {
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncAlbumModel)?.album.isMainAlbum == true }),
              let model = models[index] as? AutoSyncAlbumModel
        else {
            return
        }
        
        model.isAllChecked = selectedAlbums.count == albumModels.count
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    private func updateTableView(_ updates: VoidHandler, completion: VoidHandler?) {
        tableView.performBatchUpdates({
            updates()
        }, completion: { _ in
            completion?()
        })
    }
    
    @objc private func collapseCells(tap: UITapGestureRecognizer) {
        let location = tap.location(in: tableView)
        guard tableView.indexPathForRow(at: location) == nil else {
            return
        }
    
        //hide albums at first tap
        //if albums is collapsed we need to hide photo and video settings
        
        if let albumsHeaderCell = cellForHeader(type: .albums), albumsHeaderCell.isExpanded {
            albumsHeaderCell.didSelect()
        } else {
            if let photoHeaderCell = cellForHeader(type: .photo), photoHeaderCell.isExpanded {
                photoHeaderCell.didSelect()
            }
            if let videoHeaderCell = cellForHeader(type: .video), videoHeaderCell.isExpanded {
                videoHeaderCell.didSelect()
            }
        }
    }
    
    private func cellForHeader(type: AutoSyncHeaderType) -> AutoSyncHeaderTableViewCell? {
        guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == type }),
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? AutoSyncHeaderTableViewCell else {
            return nil
        }
        
        return cell
    }
    
    private func showHideAutosyncSettings(isShow: Bool) {
        if isShow {
            guard models.first(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .photo }) == nil else {
                return
            }
            
            let settingModels = [AutoSyncHeaderModel(type: .photo, setting: autoSyncSetting.photoSetting, isSelected: false),
                                 AutoSyncHeaderModel(type: .video, setting: autoSyncSetting.videoSetting, isSelected: false)]
            
            models.insert(contentsOf: settingModels, at: 1)
            let indexPaths = (1...settingModels.count).map { IndexPath(row: $0, section: 0) }
            
            updateTableView({
                tableView.insertRows(at: indexPaths, with: tableViewAnimationType)
            }, completion: { [weak self] in
                self?.updateAlbums(isSelected: nil)
            })
        } else {
            guard models.first(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .photo }) != nil else {
                return
            }
            
            guard let index = models.firstIndex(where: { ($0 as? AutoSyncHeaderModel)?.headerType == .albums }) else {
                return
            }
            
            let indexPaths = (1...index-1).reversed().map { i -> IndexPath in
                models.remove(at: i)
                return IndexPath(row: i, section: 0)
            }
        
            updateTableView({
                tableView.deleteRows(at: indexPaths, with: tableViewAnimationType)
            }, completion: { [weak self] in
                self?.updateAlbums(isSelected: nil)
            })
        }
    }
}

