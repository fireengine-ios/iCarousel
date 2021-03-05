//
//  FileInfoTableViewAdapter.swift
//  Depo
//
//  Created by Anton Ignatovich on 24.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol FileInfoTableViewAdapterDelegate: class {
    func didSelect(contact: SharedContact, adapter: FileInfoTableViewAdapter)
    func didTappedPlusButton(adapter: FileInfoTableViewAdapter)
    func didTappedArrowButton(sharedFileInfo: SharedFileInfo, adapter: FileInfoTableViewAdapter)
}

final class FileInfoTableViewAdapter: NSObject {

    private weak var tableView: UITableView?
    private weak var delegate: FileInfoTableViewAdapterDelegate?

    private var mainHeader: String? {
        didSet {
            infoHeaderView.updateText(to: mainHeader)
        }
    }
    
    private var dataSource: [InfoEntityDataSourceItem] = []
    private var masterEntityObject: FileInfoTableViewGeneralEntity? {
        didSet {
            reloadContent()
        }
    }
    private var sharingInfo: SharedFileInfo?

    private lazy var infoHeaderView: EntityInfoHeader = EntityInfoHeader()
    private lazy var sharingInfoHeaderView: EntityInfoHeader = {
        let vview =  EntityInfoHeader()
        vview.needsSeparatorViewOnTop = true
        vview.updateText(to: TextConstants.infoPageItemSharingInfo)
        return vview
    }()

    convenience init(with tableView: UITableView,
                     delegate fileInfoShareViewDelegate: FileInfoTableViewAdapterDelegate) {
        self.init()
        self.tableView = tableView
        self.delegate = fileInfoShareViewDelegate
        tableView.delegate = self
        tableView.dataSource = self
        setupTableView()
    }

    private func setupTableView() {
        tableView?.tableFooterView = UIView()
        tableView?.register(EntityInfoItemTableViewCell.self, forCellReuseIdentifier: String(describing: EntityInfoItemTableViewCell.self))
        tableView?.register(SharingInfoTableViewCell.self, forCellReuseIdentifier: String(describing: SharingInfoTableViewCell.self))
        tableView?.separatorColor = .clear
    }

    func update(with wrapData: WrapData) {
        masterEntityObject = FileInfoTableViewGeneralEntity.from(wrapData)
    }

    func update(with entity: SharedFileInfo) {
        sharingInfo = entity
        masterEntityObject = FileInfoTableViewGeneralEntity.from(entity)
    }

    private func reloadContent() {
        defer {
            tableView?.reloadData()
        }

        guard let masterEntity = masterEntityObject else {
            dataSource = []
            return
        }

        dataSource = InfoEntityDataSourceItem.prepareDataSource(from: masterEntity)
                                            .sorted(by: { return $0.orderIndex < $1.orderIndex })
        mainHeader = masterEntity.isFolder ? TextConstants.infoPageTitleForFolder : TextConstants.infoPageTitleForFile
    }
}

extension FileInfoTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return infoHeaderView
        case 1:
            return sharingInfoHeaderView
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1:
            return 56
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 52
        case 1:
            return 94
        default:
            return 0.1
        }
    }
}

extension FileInfoTableViewAdapter: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let masterEntity = masterEntityObject else { return 0 }
        return masterEntity.sharedToMembersCount > 0 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return dataSource.count
        case 1:
            return 1
        default:
            return 0
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EntityInfoItemTableViewCell.self), for: indexPath) as? EntityInfoItemTableViewCell {
                let item = dataSource[indexPath.row]
                cell.setup(with: item.key, and: item.value)
                cell.selectionStyle = .none
                return cell
            }
        case 1:
            guard let sharingInfo = sharingInfo else {
                assertionFailure("[FileInfoTableViewAdapter] expected SharedFileInfo to be non nil value")
                return UITableViewCell()
            }

            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SharingInfoTableViewCell.self), for: indexPath) as? SharingInfoTableViewCell {
                cell.setup(with: sharingInfo)
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
        default: break
        }

        return UITableViewCell()
    }
}

// MARK: - SharingInfoTableViewCellDelegate
extension FileInfoTableViewAdapter: SharingInfoTableViewCellDelegate {
    func didSelect(contact: SharedContact, cell: SharingInfoTableViewCell) {
        delegate?.didSelect(contact: contact, adapter: self)
    }

    func didTappedPlusButton(cell: SharingInfoTableViewCell) {
        delegate?.didTappedPlusButton(adapter: self)
    }

    func didTappedArrowButton(sharedEntityItem: SharedFileInfo, cell: SharingInfoTableViewCell) {
        delegate?.didTappedArrowButton(sharedFileInfo: sharedEntityItem, adapter: self)
    }
}

fileprivate struct InfoEntityDataSourceItem {
    let orderIndex: Int
    let key: String
    let value: String

    static func prepareDataSource(from sharingInfo: FileInfoTableViewGeneralEntity) -> [InfoEntityDataSourceItem] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy - hh:mm"

        var creationDate: String = ""
        if let sharingInfoCreationDate = sharingInfo.creationDate {
            creationDate = dateFormatter.string(from: sharingInfoCreationDate)
        }

        var lastModifiedDate: String = ""
        if let sharingInfoModifiedDate = sharingInfo.lastModifiedDate {
            lastModifiedDate = dateFormatter.string(from: sharingInfoModifiedDate)
        }

        var dataArr = [
            (0, TextConstants.infoPageItemName, sharingInfo.name),
            (2, TextConstants.infoPageItemCreationDate, creationDate),
            (3, TextConstants.infoPageItemModifiedDate, lastModifiedDate)
        ]

        if sharingInfo.isFolder {
            dataArr.append((1, TextConstants.infoPageItemItems, "\(sharingInfo.childCount ?? 0)"))
        } else {
            dataArr.append((1, TextConstants.infoPageItemSize, String(format: "%.2f", Double(sharingInfo.bytes ?? 0) / 1000000.0) + " MB"))
        }

        return dataArr.compactMap { InfoEntityDataSourceItem(orderIndex: $0.0,
            key: $0.1,
            value: $0.2) }
    }
}

fileprivate struct FileInfoTableViewGeneralEntity {
    let name: String
    let creationDate: Date?
    let lastModifiedDate: Date?
    let isFolder: Bool
    let bytes: Int64?
    let childCount: Int64?
    let sharedToMembersCount: Int

    static func from(_ remoteFileInfo: SharedFileInfo) -> FileInfoTableViewGeneralEntity {
        return FileInfoTableViewGeneralEntity(name: remoteFileInfo.name ?? "",
                                              creationDate: remoteFileInfo.createdDate,
                                              lastModifiedDate: remoteFileInfo.lastModifiedDate,
                                              isFolder: remoteFileInfo.folder ?? false,
                                              bytes: remoteFileInfo.bytes,
                                              childCount: remoteFileInfo.childCount,
                                              sharedToMembersCount: remoteFileInfo.members?.count ?? 0)
    }

    static func from(_ passedInData: WrapData) -> FileInfoTableViewGeneralEntity {
        return FileInfoTableViewGeneralEntity(name: passedInData.name ?? "",
                                              creationDate: passedInData.creationDate,
                                              lastModifiedDate: passedInData.lastModifiDate,
                                              isFolder: passedInData.isFolder ?? false,
                                              bytes: passedInData.fileSize,
                                              childCount: passedInData.childCount,
                                              sharedToMembersCount: 0)
    }
}

