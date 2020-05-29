//
//  ContactListDataSource.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 5/29/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol ContactListDataSourceDelegate: class {
    func needLoadNextItemsPage()
}

private typealias InsertItemResult = (indexPath: IndexPath?, section: Int?)
private typealias ChangesItemResult = (indexPaths: [IndexPath], sections: IndexSet)

final class ContactListDataSource: NSObject {
    
    private let tableView: UITableView
    private weak var delegate: ContactListDataSourceDelegate?
    
    private var contacts = [[RemoteContact]]()
    private var sectionTitles = [String]()
    
    private var isPaginationDidEnd = false
    
    required init(tableView: UITableView, delegate: ContactListDataSourceDelegate?) {
        self.tableView = tableView
        self.delegate = delegate
        super.init()
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(nibCell: ContactListCell.self)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.sectionHeaderHeight = 48
        tableView.rowHeight = 52
    }

    func reset() {
        sectionTitles.removeAll()
        contacts.removeAll()
        tableView.reloadData()
    }
    
    func append(newContacts: [RemoteContact], completion: @escaping VoidHandler) {
        if newContacts.isEmpty {
            isPaginationDidEnd = true
        }
        
        let isEmpty = contacts.isEmpty
        let insertResult = self.append(newContacts: newContacts)
        guard !insertResult.indexPaths.isEmpty else {
            completion()
            return
        }
        
        if isEmpty {
            tableView.reloadData()
            completion()
        } else {
            updateTableView({
                if !insertResult.sections.isEmpty {
                    tableView.insertSections(insertResult.sections, with: .automatic)
                }
                tableView.insertRows(at: insertResult.indexPaths, with: .automatic)
            }, completion: completion)
        }
    }

}

//MARK: - Private methods

private extension ContactListDataSource {
    
    func item(for indexPath: IndexPath) -> RemoteContact? {
        return contacts[safe: indexPath.section]?[indexPath.row]
    }
    
    func append(newContacts: [RemoteContact]) -> ChangesItemResult {
        var insertedIndexPaths = [IndexPath]()
        var insertedSections = IndexSet()
        
        let allContacts = contacts.flatMap { $0 }
        let insertContacts = newContacts.filter { !allContacts.contains($0) }
        
        for contact in insertContacts {
            autoreleasepool {
                let insertResult: InsertItemResult?
                if !contacts.isEmpty, let lastContact = contacts.last?.last {
                    insertResult = addByName(lastContact: lastContact, newContact: contact)
                } else {
                    insertResult = appendSection(with: contact)
                }
                
                if let indexPath = insertResult?.indexPath {
                    insertedIndexPaths.append(indexPath)
                }
                
                if let section = insertResult?.section {
                    insertedSections.insert(section)
                }
            }
        }
        return (insertedIndexPaths, insertedSections)
    }
    
    private func addByName(lastContact: RemoteContact, newContact: RemoteContact) -> InsertItemResult {
        let lastContactFirstLetter = lastContact.name.firstLetter
        let newContactFirstLetter = newContact.name.firstLetter
        
        if !lastContactFirstLetter.isEmpty, !newContactFirstLetter.isEmpty,
            lastContactFirstLetter == newContactFirstLetter,
            !contacts.isEmpty {
            return appendInLastSection(newContact: newContact)
        } else {
            return appendSection(with: newContact)
        }
    }
    
    private func appendSection(with newContact: RemoteContact) -> InsertItemResult {
        let section = contacts.count
        let indexPath = IndexPath(row: 0, section: section)
        contacts.append([newContact])
        sectionTitles.append(newContact.name.firstLetter)
        return (indexPath, section)
    }
    
    private func appendInLastSection(newContact: RemoteContact) -> InsertItemResult {
        guard !contacts.isEmpty else {
            assertionFailure()
            return (nil, nil)
        }
        
        let section = contacts.count - 1
        let row = contacts[section].count
        let indexPath = IndexPath(item: row, section: section)
        contacts[section].append(newContact)
        return (indexPath, nil)
    }
    
    private func updateTableView(_ updates: VoidHandler, completion: VoidHandler?) {
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

//MARK: - UITableViewDataSource

extension ContactListDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeue(reusable: ContactListCell.self, for: indexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        index
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ContactListSectionHeader()
        header.setup(with: sectionTitles[section])
        return header
    }
}

//MARK: - UITableViewDelegate

extension ContactListDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ContactListCell, let contact = item(for: indexPath) else {
            return
        }
        
        cell.configure(with: contact)
        
        if isPaginationDidEnd {
            return
        }

        let countRow = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let isLastCell = countRow - 1 == indexPath.row && indexPath.section == tableView.numberOfSections - 1

        if isLastCell {
            delegate?.needLoadNextItemsPage()
        }
    }
}
