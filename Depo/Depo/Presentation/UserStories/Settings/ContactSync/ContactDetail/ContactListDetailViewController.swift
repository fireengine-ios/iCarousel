//
//  ContactListDetailViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactListDetailViewController: BaseViewController, NibInit {

    static func with(contact: RemoteContact) -> ContactListDetailViewController {
        let controller = Self.initFromNib()
        controller.contact = contact
        return controller
    }
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var contact: RemoteContact?
    private var cellsInfo = [ContactDetailInfo]()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(withString: TextConstants.contactDetailNavBarTitle)
        
        setupTableView()
        setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView.tableHeaderView == nil {
            setupHeader()
        }
    }
    
    private func setupHeader() {
        guard let contact = contact else {
            assertionFailure()
            return
        }
        
        let header = ContactDetailHeader.initFromNib()
        header.configure(with: contact)
        
//        let size = header.sizeToFit(width: tableView.bounds.width)
//        header.frame.size = size
        
        tableView.tableHeaderView = header
    }
    
    private func setupTableView() {
        tableView.register(nibCell: ContactDetailCell.self)
        tableView.register(nibCell: ContactDetailNoInfoCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
    }
    
    private func setupData() {
        guard let contact = contact else {
            assertionFailure()
            return
        }
        
        if !contact.phones.isEmpty {
            let phoneInfo = ContactDetailInfo(category: .phone, values: contact.phones)
            cellsInfo.append(phoneInfo)
        }
        
        if !contact.emails.isEmpty {
            let emailInfo = ContactDetailInfo(category: .email, values: contact.emails)
            cellsInfo.append(emailInfo)
        }
        
        if !contact.addresses.isEmpty {
            let addressesInfo = ContactDetailInfo(category: .address, values: contact.addresses.map { $0.displayAddress })
            cellsInfo.append(addressesInfo)
        }
        
        //Uncomment in future
//        if !contact.birthDate.isEmpty {
//            let birthDateInfo = ContactDetailInfo(category: .birthday, values: [contact.birthDate])
//            cellsInfo.append(birthDateInfo)
//        }
        
//        if !contact.notes.isEmpty {
//            let notesInfo = ContactDetailInfo(category: .notes, values: [contact.notes])
//            cellsInfo.append(notesInfo)
//        }
        
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension ContactListDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellsInfo.isEmpty {
            return 1
        }
        return cellsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cellsInfo.isEmpty {
            return tableView.dequeue(reusable: ContactDetailNoInfoCell.self, for: indexPath)
        }
        
        let cell = tableView.dequeue(reusable: ContactDetailCell.self, for: indexPath)
        cell.configure(with: cellsInfo[indexPath.row])
        return cell
    }
}
