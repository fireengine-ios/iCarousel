//
//  ContactBackupDataProvider.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol ContactBackupHistoryDataManagerProtocol: class {
    func setup(with items: [ContactBackupItem])
}

protocol ContactBackupHistoryDataManagerDelegate: class {
    func showDetailsForBackupItem(item: ContactBackupItem)
}

final class ContactBackupHistoryDataManager: NSObject, ContactBackupHistoryDataManagerProtocol {
    
    private var tableView: UITableView
    
    weak var delegate: ContactBackupHistoryDataManagerDelegate?
    
    init(tableView: UITableView, delegate: ContactBackupHistoryDataManagerDelegate) {
        self.tableView = tableView
        super.init()
        self.delegate = delegate
        setupTableView()
    }
    
    private var contactBackups = [ContactBackupItem]()
    private(set) var selectedBackup: ContactBackupItem?
    
    func setup(with items: [ContactBackupItem]) {
        contactBackups = items
        selectedBackup = items.first
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(nibCell: ContactsBackupCell.self)
        tableView.allowsSelection = true
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func prepareInfoForCellPresenting(for item: ContactBackupItem) -> (title: String, description: String) {
        let title = TextConstants.contactBackupHistoryCellContactList
        let description: String
        if let date = item.created {
            description = "\(item.total) \(TextConstants.contactBackupHistoryCellTitle) | \(String(describing: date.getDateInFormat(format: "dd MMM yyyy '|' HH:mm")))"
        } else {
            description = "\(item.total) \(TextConstants.contactBackupHistoryCellTitle)"
        }
        return (title: title, description: description)
    }
}

//MARK: - UITableViewDataSource

extension ContactBackupHistoryDataManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactBackups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(reusable: ContactsBackupCell.self, for: indexPath)
    }
}

//MARK: - UITableViewDelegate

extension ContactBackupHistoryDataManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard var cell = cell as? ContactsBackupCellProtocol else {
            assertionFailure()
            return
        }
        
        let backup = contactBackups[indexPath.row]
        let cellInfo = prepareInfoForCellPresenting(for: backup)
        cell.setupCell(title: cellInfo.title, detail: cellInfo.description, isSelected: backup == selectedBackup)
        cell.delegate = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contactBackups[indexPath.row]
        delegate?.showDetailsForBackupItem(item: item)
        tableView.deselectRow(at: indexPath, animated: true)
     }
}

extension ContactBackupHistoryDataManager: ContactsBackupCellDelegate {
    
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }

        if let backup = selectedBackup, let index = contactBackups.index(of: backup),
           var oldSelectedCell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ContactsBackupCellProtocol {
            oldSelectedCell.isCellSelected = false
        }
        
        selectedBackup = contactBackups[indexPath.row]
    }
}

