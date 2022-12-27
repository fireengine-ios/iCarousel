//
//  PackagesPackagesViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class PackagesViewController: BaseViewController {
    var output: PackagesViewOutput!
    
    @IBOutlet weak private var cardsTableView: UITableView! {
        willSet {
            newValue.delaysContentTouches = true
            newValue.rowHeight = UITableView.automaticDimension
            newValue.register(nibCell: PackagesTableViewCell.self)
            newValue.tableFooterView = UIView()
            newValue.isScrollEnabled = false
        }
    }
    
    @IBOutlet weak private var scrollView: ControlContainableScrollView! {
        willSet {
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet weak private var cardsStackView: UIStackView!

    private var menuViewModels: [ControlPackageType] = [.myProfile, .usage(percentage: 0), .connectedAccounts]
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        setTitle(withString: TextConstants.accountDetails)
        
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        self.view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
    }
}

// MARK: PackagesViewInput
extension PackagesViewController: PackagesViewInput {
    func setupStackView(with percentage: CGFloat) {
        menuViewModels.removeAll()
        cardsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        ///my profile card
        addNewCard(type: .myProfile)
        
        ///my usage card
        addNewCard(type: .usage(percentage: percentage))
        
        //connectedAccountsCard
        addNewCard(type: .connectedAccounts)
        
        cardsTableView.reloadData()
    }
    
    private func addNewCard(type: ControlPackageType) {
        if Device.isIpad {
            let card = PackageInfoView.initFromNib()
            card.configure(with: type)
            
            output.configureCard(card)
            cardsStackView.addArrangedSubview(card)
        } else {
            menuViewModels.append(type)
        }
    }
}

// MARK: - UITableViewDataSource
extension PackagesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeue(reusable: PackagesTableViewCell.self)
    }
}

// MARK: - UITableViewDelegate
extension PackagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        guard let item = menuViewModels[safe: indexPath.row] else {
            return
        }
        
        let cell = cell as? PackagesTableViewCell
        cell?.configure(type: item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = menuViewModels[safe: indexPath.row] else {
            return
        }
        
        let delegate = output as? PackageInfoViewDelegate
        delegate?.onSeeDetailsTap(with: item)
    }
}
