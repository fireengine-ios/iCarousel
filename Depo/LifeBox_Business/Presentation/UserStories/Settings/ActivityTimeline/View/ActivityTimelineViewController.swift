//
//  ActivityTimelineActivityTimelineViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ActivityTimelineViewController: BaseViewController {
    var output: ActivityTimelineViewOutput!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let sectionBuilder = ActivityTimelineSectionsBuider()
    private var isSettedInfinityScroll = false
    private var isLoadingMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.activityTimelineTitle)
        setupTableView()
        setupPullToRefresh()
        
        output.viewIsReady()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarStyle(.byDefault)
    }
    
    private func setupTableView() {
        tableView.register(nibHeaderFooter: ActivityTimelineHeader.self)
        tableView.register(nibCell: ActivityTimelineTimeCell.self)
        tableView.register(nibCell: ActivityTimelineFileCell.self)
    }
    
    private var refreshControl: UIRefreshControl?
    
    private func setupPullToRefresh() {
        refreshControl = tableView.addRefreshControl { [weak self] _ in
            self?.reloadData()
        }
    }
    
    private func setupInfinityScroll() {
        tableView.tableFooterView = getInfinityView()
    }
    
    private func getInfinityView() -> UIView {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.startAnimating()
        return activity
    }
    
    private func reloadData() {
        guard !isLoadingMore else {
            return
        }
        isLoadingMore = true
        output.updateForPullToRefresh()
    }
    
    private func loadMoreData() {
        guard !isLoadingMore else {
            return
        }
        isLoadingMore = true
        output.loadMoreActivities()
    }
    
    private func endFooterRefreshing() {
        isLoadingMore = false
    }
}

// MARK: - ActivityTimelineViewInput
extension ActivityTimelineViewController: ActivityTimelineViewInput {
    
    func displayTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        sectionBuilder.setup(with: array)
        endFooterRefreshing()
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    func refreshTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        sectionBuilder.clear()
        sectionBuilder.setup(with: array)
        endFooterRefreshing()
        refreshControl?.endRefreshing()
        tableView.reloadData()
        
        if !isSettedInfinityScroll {
            tableView.backgroundView = ActivityTimelineTableBackView.fromNib
            setupInfinityScroll()
        }
        
        if tableView.contentSize.height < tableView.frame.height {
            endInfinityScrollWithNoMoreData()
        }
    }
    
    func endInfinityScrollWithNoMoreData() {
        endFooterRefreshing()
        tableView.tableFooterView = nil
    }
}

// MARK: - UITableViewDataSource
extension ActivityTimelineViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionBuilder.numberOfBigSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionBuilder.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sectionBuilder.cell(for: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ActivityTimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionBuilder.header(for: tableView, viewForHeaderInSection: section)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionBuilder.heightForHeaderInSection
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastSection = (numberOfSections(in: tableView) - 1) == indexPath.section
        guard isLastSection else {
            return
        }
        
        let countRow: Int = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let isLastCell = indexPath.row == countRow - 1
        if isLastCell {
            loadMoreData()
        }
    }
}
