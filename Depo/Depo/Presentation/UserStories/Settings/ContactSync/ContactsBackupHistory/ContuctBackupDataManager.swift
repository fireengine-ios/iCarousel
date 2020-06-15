//
//  ContuctBackupDataProvider.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

typealias ContactBuckupItem = ContactSync.SyncResponse

protocol ContuctBackupHistoryDataManagerProtocol: class {
    func appendItemsForPresent(items: [ContactBuckupItem])
    func getSelectedItems() -> [ContactBuckupItem]
}

protocol ContuctBackupHistoryDataManagerDelegate: class {
    func showDetailsForBuckupItem(item: ContactBuckupItem)
}

//TODO: Change logic/ uncomment when new logic (with cell selection mode) will be implemented

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
    
//    private var contactBackups = [ContactBuckupItem]() {
//        didSet {
//            tableView.reloadData()
//        }
//    }
    
    private var selectedItems = [ContactBuckupItem]() {
        didSet {
            // remove did set
            tableView.reloadData()
        }
    }
    
    func appendItemsForPresent(items: [ContactBuckupItem]) {
      //contactBackups.append(contentsOf: items)
        selectedItems.append(contentsOf: items)
    }
    
    func getSelectedItems() -> [ContactBuckupItem] {
        return selectedItems
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
    
    private func prepareInfoForCellPresenting(for item: ContactBuckupItem) -> (title: String, description: String) {
        guard let date = item.date else {
            assertionFailure()
            return (title: TextConstants.contactBackupHistoryCellTitle, description: "")
        }
        
        let title = TextConstants.contactBackupHistoryCellContactList
        let description = "\(item.totalNumberOfContacts) \(TextConstants.contactBackupHistoryCellTitle) |  \(String(describing: date.getDateInFormat(format: "dd MMM yyyy")))"
        return (title: title, description: description)
    }
}

extension ContuctBackupHistoryDataManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {   //contactBackups.count
        selectedItems.count
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
     }
}

extension ContuctBackupHistoryDataManager: ContactsBackupCellDelegate {
    
    func selectCellButtonTapped(for cell: UITableViewCell & ContactsBackupCellProtocol) {
//        guard let indexPath = tableView.indexPath(for: cell) else {
//            assertionFailure()
//            return
//        }

//        manageSelectionStateForCell(cell, indexPath: indexPath, isWillDisplayFunc: false)
    }
}

