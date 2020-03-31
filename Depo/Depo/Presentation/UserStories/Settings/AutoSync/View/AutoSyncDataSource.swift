//
//  AutoSyncSettingsDataSource.swift
//  Depo
//
//  Created by Andrei Novikau on 3/6/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol AutoSyncDataSourceDelegate: class {
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
    
    var autoSyncAlbums: [AutoSyncAlbum] {
        return models.compactMap { ($0 as? AutoSyncAlbumModel)?.album }
    }
    
    var isFromSettings = false
    
    private let tableViewAnimationType = UITableView.RowAnimation.top
    
    //MARK: - Init
    
    init(tableView: UITableView, delegate: AutoSyncDataSourceDelegate?) {
        self.tableView = tableView
        self.delegate = delegate
        super.init()
        
        setupTableView()
        setupDefaultState()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        
        AutoSyncRowType.cellTypes.forEach { tableView.register(nibCell: $0.self) }
        
        //need for correct hide animation bottom cells
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: Device.winSize.width, height: 150))
        footer.backgroundColor = .white
        let line = UIView(frame: CGRect(x: 16, y: 0, width: Device.winSize.width - 32, height: 1))
        line.backgroundColor = ColorConstants.profileGrayColor
        footer.addSubview(line)
        tableView.tableFooterView = footer
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
        
        if autoSyncSetting.isAutoSyncOptionEnabled {
            enableAutoSync()
        } else {
            forceDisableAutoSync()
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
}

//MARK: - UITableViewDataSource

extension AutoSyncDataSource: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        
        guard let cell = tableView.dequeue(reusable: model.type.cellClass().self, for: indexPath) as? AutoSyncTableViewCell else {
            assertionFailure()
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.setup(with: model, delegate: self)
        
        return cell
    }
}
 
//MARK: - UITableViewDelegate

extension AutoSyncDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AutoSyncTableViewCell {
            cell.didSelect()
            tableView.deselectRow(at: indexPath, animated: false)
        }
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
}

//MARK: - AutoSyncCellDelegate

extension AutoSyncDataSource: AutoSyncCellDelegate {
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
                } else {
                    hideAlbums()
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
        
        updateTableView({
            tableView.deleteRows(at: indexPaths, with: tableViewAnimationType)
        }, completion: nil)
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

    func updateTableView(_ updates: VoidHandler, completion: VoidHandler?) {
        if #available(iOS 11.0, *) {
            tableView.performBatchUpdates({
                updates()
            }, completion: { _ in
                completion?()
            })
        } else {
            tableView.beginUpdates()
            updates()
            tableView.endUpdates()
            completion?()
        }
    }
}

