//
//  DiscoverViewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class DiscoverViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var output: DiscoverViewOutput!
    private lazy var shareCardContentManager = ShareCardContentManager(delegate: self)
    var modelPlaces = [WrapData]()
    var modelCards = [HomeCardResponse]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("Discover viewDidLoad")

        configureUI()
        output.viewIsReady()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //output.getUpdateData()
    }
    
    private func configureUI() {
        navigationBarHidden = true
        needToShowTabBar = true
        setDefaultNavigationHeaderActions()
        headerContainingViewController?.isHeaderBehindContent = false
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(nibCell: DiscoverTableViewCell.self)
    }
    
}
extension DiscoverViewController: DiscoverViewInput {
    func didGetUpdateData() {
        print("xxxxxx")
    }
    
    func didFinishedAllRequests() {
        DispatchQueue.main.async {
            self.modelCards = self.output.getModelCards() as! [HomeCardResponse]
            //self.modelCards = self.modelCards.filter({$0.type == .paycell || $0.type == .invitation || $0.type == .drawCampaign || $0.type == .emptyStorage })
            self.configureTableView()
            self.tableView.reloadData()
        }
    }
    
    func stopRefresh() {
        hideSpinner()
    }
}

extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: DiscoverTableViewCell.self, for: indexPath)
        cell.configure(with: modelCards[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.navigate(for: modelCards[indexPath.row].type ?? .paycell)
    }
}

extension DiscoverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height / 4.63
    }
    
}



extension DiscoverViewController: HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? { tableView }
}

extension DiscoverViewController: ShareCardContentManagerDelegate {
    func shareOperationStarted() {
        showSpinner()
    }
    
    func shareOperationFinished() {
        hideSpinner()
    }
}
