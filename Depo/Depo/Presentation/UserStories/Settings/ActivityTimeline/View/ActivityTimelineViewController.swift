//
//  ActivityTimelineActivityTimelineViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ActivityTimelineViewController: ViewController {
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
        
        isLoadingMore = true
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    private func setupTableView() {
        tableView.register(nibHeaderFooter: ActivityTimelineHeader.self)
        tableView.register(nibCell: ActivityTimelineTimeCell.self)
        tableView.register(nibCell: ActivityTimelineFileCell.self)
    }
    
    private var refreshControl: UIRefreshControl?
    
    private func setupPullToRefresh() {
        refreshControl = tableView.addRefreshControl { [weak self] _ in
            self?.output.updateForPullToRefresh()
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
    
    private func loadMoreData() {
        if isLoadingMore {
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
}

// MARK: - UIScrollViewDelegate
extension ActivityTimelineViewController: UIScrollViewDelegate {
    
    /// Infinite Scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if deltaOffset(for: scrollView) <= 0 {
            loadMoreData()
        }
    }
    
    private func deltaOffset(for scrollView: UIScrollView) -> CGFloat {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.height
        let infinity = tableView.tableFooterView?.bounds.height ?? 0
        return maximumOffset - currentOffset - infinity
    }
}
