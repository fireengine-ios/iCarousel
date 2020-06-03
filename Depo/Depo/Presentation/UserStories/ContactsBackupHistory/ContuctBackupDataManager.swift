//
//  ContuctBackupDataProvider.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

typealias ContactBuckupItem = String

protocol ContuctBackupHistoryDataManagerProtocol: class {
    func appendItemsForPresent(items: [ContactBuckupItem])
    func getSelectedItems() -> [ContactBuckupItem]
}

protocol ContuctBackupHistoryDataManagerDelegate: class {
    func showDetailsForBuckupItem(item: ContactBuckupItem)
}

final class ContuctBackupHistoryDataManager: NSObject, ContuctBackupHistoryDataManagerProtocol {
    
    private var tableView: UITableView
    
    weak var delegate: ContuctBackupHistoryDataManagerDelegate?
    
    init(tableView: UITableView, delegate: ContuctBackupHistoryDataManagerDelegate) {
        self.tableView = tableView
        self.tableView.register(nibCell: ContactsBackupCell.self)
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        self.delegate = delegate
    }
    
    private var contactBackups = [ContactBuckupItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var selectedItems = [ContactBuckupItem]()
    
    func appendItemsForPresent(items: [ContactBuckupItem]) {
        contactBackups.append(contentsOf: items)
    }
    
    func getSelectedItems() -> [ContactBuckupItem] {
        return selectedItems
    }
    
    private func manageSelectionStateForCell(_ cell: ContactsBackupCellProtocol, indexPath: IndexPath, isWillDisplayFunc: Bool) {
        let item = contactBackups[indexPath.row]
        if selectedItems.contains(item) {
            if isWillDisplayFunc {
                cell.manageSelectionState(isCellSelected: true)
            } else {
                cell.manageSelectionState(isCellSelected: false)
                selectedItems.remove(item)
            }
        } else {
            if isWillDisplayFunc {
                cell.manageSelectionState(isCellSelected: false)
            } else {
                selectedItems.append(item)
                cell.manageSelectionState(isCellSelected: true)
            }
        }
    }
}

extension ContuctBackupHistoryDataManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contactBackups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(reusable: ContactsBackupCell.self, for: indexPath)
    }
}

extension ContuctBackupHistoryDataManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard var cell = cell as? ContactsBackupCellProtocol else {
            assertionFailure()
            return
        }
        let item = contactBackups[indexPath.row]
        cell.setupCell(title: item, detail: item)
        cell.delegate = self
        manageSelectionStateForCell(cell, indexPath: indexPath, isWillDisplayFunc: true)
    }
}

extension ContuctBackupHistoryDataManager: ContactsBackupCellDelegate {
    
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        manageSelectionStateForCell(cell, indexPath: indexPath, isWillDisplayFunc: false)
    }
    
    func arrowButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            assertionFailure()
            return
        }
        
        let item = contactBackups[indexPath.row]
        delegate?.showDetailsForBuckupItem(item: item)
    }
}

