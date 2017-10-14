//
//  ActivityTimelineActivityTimelineViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 13/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import PullToRefreshKit

class ActivityTimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var output: ActivityTimelineViewOutput!
    private let sectionBuilder = ActivityTimelineSectionsBuider()
    private var isSettedInfinityScroll = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.activityTimelineTitle)
        setupTableView()
        setupPullToRefresh()
        output.viewIsReady()
    }
    
    private func setupTableView() {
        tableView.register(nibHeaderFooter: ActivityTimelineHeader.self)
        tableView.register(nibCell: ActivityTimelineTimeCell.self)
        tableView.register(nibCell: ActivityTimelineFileCell.self)
    }
    
    private func setupPullToRefresh() {
        tableView.setUpHeaderRefresh { [weak self] in
            self?.output.updateForPullToRefresh()
        }.setupForLifeBox()
    }
    
    private func setupInfinityScroll() {
        tableView.setUpFooterRefresh { [weak self] in
            self?.output.loadMoreActivities()
        }.setupForLifeBox()
    }
}

// MARK: - ActivityTimelineViewInput
extension ActivityTimelineViewController: ActivityTimelineViewInput {
    
    func displayTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        sectionBuilder.setup(with: array)
        tableView.endFooterRefreshing()
        tableView.reloadData()
    }
    
    func refreshTimelineActivities(with array: [ActivityTimelineServiceResponse]) {
        sectionBuilder.clear()
        sectionBuilder.setup(with: array)
        tableView.endHeaderRefreshing()
        tableView.reloadData()
        
        if !isSettedInfinityScroll {
            tableView.backgroundView = ActivityTimelineTableBackView.fromNib
            setupInfinityScroll()
        }
    }
    
    func endInfinityScrollWithNoMoreData() {
        tableView.endFooterRefreshingWithNoMoreData()
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
