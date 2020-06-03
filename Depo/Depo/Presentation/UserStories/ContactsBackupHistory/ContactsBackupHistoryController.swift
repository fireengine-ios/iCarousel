//
//  ContactsBuckupDetails.swift
//  Depo
//
//  Created by Maxim Soldatov on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactsBackupHistoryController: ViewController {

    private let contactHistoryView = ContactsBackupHistoryView.initFromNib()
    private var dataManager: ContuctBackupHistoryDataManagerProtocol?
    private let router = RouterVC()
    
    override func loadView() {
        view = contactHistoryView
        contactHistoryView.delegate = self
        dataManager = ContuctBackupHistoryDataManager(tableView: contactHistoryView.tableView,
                                                      delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Here example how to add 
        dataManager?.appendItemsForPresent(items: ["Hello", "Hello1"])
    }
}

extension ContactsBackupHistoryController: ContuctBackupHistoryDataManagerDelegate {
    func showDetailsForBuckupItem(item: ContactBuckupItem) {
        //TODO: Here logic for show detail of selected backup, when user tap on
        // arrow button
    }
}

extension ContactsBackupHistoryController: ContactsBackupHistoryViewDelegate {
    func restoreBackupTapped() {
        let popup = ContactBackupHistoryPopupFactory.restore.createPopup { _ in
            //TODO: Logic for restore
            print("Ok tapped")
        }
        router.presentViewController(controller: popup)
    }
    
    func deleteBackupTapped() {
        let popup = ContactBackupHistoryPopupFactory.delete.createPopup { _ in
            ///TODO: Logic for delete
            print("Ok tapped")
        }
        router.presentViewController(controller: popup)
    }
}

