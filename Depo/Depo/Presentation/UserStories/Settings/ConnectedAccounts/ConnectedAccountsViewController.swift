//
//  ConnectedAccountsViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 24/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum SocialAccount: Int {
    case instagram
    case facebook
    case dropbox
}


final class ConnectedAccountsViewController: ViewController, ErrorPresenter {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var activityManager = ActivityIndicatorManager()
    
    private let sections: [SocialAccount] = [.instagram, .facebook, .dropbox]
    
    
    static func initialize() -> ConnectedAccountsViewController {
        return ConnectedAccountsViewController(nibName: "ConnectedAccountsViewController", bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        
        let reusableIds = [CellsIdConstants.instagramAccountConnectionCell,
                           CellsIdConstants.facebookAccountConnectionCell,
                           CellsIdConstants.dropboxAccountConnectionCell]
        
        for id in reusableIds {
            let nib = UINib(nibName: id, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: id)
        }
    }
}


extension ConnectedAccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = cellIdentifier(for: indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
    
    private func cellIdentifier(for section: Int) -> String {
        guard let accountType = SocialAccount(rawValue: section) else {
            assertionFailure("wrong index")
            return ""
        }
        
        switch accountType {
        case .instagram:
            return CellsIdConstants.instagramAccountConnectionCell
        case .facebook:
            return CellsIdConstants.facebookAccountConnectionCell
        case .dropbox:
            return CellsIdConstants.dropboxAccountConnectionCell
        }
    }
}


extension ConnectedAccountsViewController: UITableViewDelegate {
    
}


// MARK: - ActivityIndicator
extension ConnectedAccountsViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}





