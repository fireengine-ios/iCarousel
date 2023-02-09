//
//  NotificationViewController.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class NotificationViewController: BaseViewController {
    var output: NotificationViewOutput!
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.delaysContentTouches = true
        view.rowHeight = UITableView.automaticDimension
        view.register(nibCell: PackagesTableViewCell.self)
        view.tableFooterView = UIView()
        view.isScrollEnabled = false
        return view
    }()
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.notificationMenuItem))
        
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
    }
}

// MARK: NotificationViewInput
extension NotificationViewController: NotificationViewInput {

}

// MARK: - UITableViewDataSource
extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(reusable: PackagesTableViewCell.self)
    }
}

// MARK: - UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.textLabel?.text = "Yilmaz Edis"
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
