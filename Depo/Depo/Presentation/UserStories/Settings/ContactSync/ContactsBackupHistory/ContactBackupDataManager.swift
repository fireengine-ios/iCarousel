//
//  ContactBackupDataProvider.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

typealias ContactBackupItem = ContactSync.SyncResponse

protocol ContactBackupHistoryDataManagerProtocol: class {
    func appendItemsForPresent(items: [ContactBackupItem])
    func getSelectedItems() -> [ContactBackupItem]
}

protocol ContactBackupHistoryDataManagerDelegate: class {
    func showDetailsForBuckupItem(item: ContactBackupItem)
}

//TODO: Change logic/ uncomment when new logic (with cell selection mode) will be implemented

final class ContactBackupHistoryDataManager: NSObject, ContactBackupHistoryDataManagerProtocol {
    
    private var tableView: UITableView
    
    weak var delegate: ContactBackupHistoryDataManagerDelegate?
    
    init(tableView: UITableView, delegate: ContactBackupHistoryDataManagerDelegate) {
        self.tableView = tableView
        super.init()
        self.delegate = delegate
        setupTableView()
    }
    
//    private var contactBackups = [ContactBuckupItem]() {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    private var selectedItems = [ContactBackupItem]() {
        didSet {
            // remove did set
            tableView.reloadData()
        }
    }
    
    func appendItemsForPresent(items: [ContactBackupItem]) {
      //contactBackups.append(contentsOf: items)
        selectedItems.append(contentsOf: items)
    }
    
    func getSelectedItems() -> [ContactBackupItem] {
        return selectedItems
    }
    
    private func setupTableView() {
        tableView.register(nibCell: ContactsBackupCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func manageSelectionStateForCell(_ cell: ContactsBackupCellProtocol, indexPath: IndexPath, isWillDisplayFunc: Bool) {
        let item = selectedItems[indexPath.row] //contactBackups[indexPath.row]
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
    
    private func prepareInfoForCellPresenting(for item: ContactBackupItem) -> (title: String, description: String) {
        guard let date = item.date else {
            assertionFailure()
            return (title: TextConstants.contactBackupHistoryCellTitle, description: "")
        }
        
        let title = TextConstants.contactBackupHistoryCellContactList
        let description = "\(item.totalNumberOfContacts) \(TextConstants.contactBackupHistoryCellTitle) |  \(String(describing: date.getDateInFormat(format: "dd MMM yyyy")))"
        return (title: title, description: description)
    }
}

//MARK: - UITableViewDataSource

extension ContactBackupHistoryDataManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {   //contactBackups.count
        selectedItems.count
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
        }                                              //contactBackups[indexPath.row]
        let cellInfo = prepareInfoForCellPresenting(for: selectedItems[indexPath.row])
        cell.setupCell(title: cellInfo.title, detail: cellInfo.description)
        cell.delegate = self
        manageSelectionStateForCell(cell, indexPath: indexPath, isWillDisplayFunc: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                  //contactBackups[indexPath.row]
        let item = selectedItems[indexPath.row]
        delegate?.showDetailsForBuckupItem(item: item)
        tableView.deselectRow(at: indexPath, animated: true)
     }
}

extension ContactBackupHistoryDataManager: ContactsBackupCellDelegate {
    
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol) {
//        guard let indexPath = tableView.indexPath(for: cell) else {
//            assertionFailure()
//            return
//        }

//        manageSelectionStateForCell(cell, indexPath: indexPath, isWillDisplayFunc: false)
    }
}

