//
//  UsageInfoViewController.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class UsageInfoViewController: UIViewController {
    var output: UsageInfoViewOutput!
    
    @IBOutlet weak fileprivate var currentPlanLabel: UILabel!
    @IBOutlet weak fileprivate var memoryUsageProgressView: RoundedProgressView!
    @IBOutlet weak fileprivate var memoryUsageLabel: UILabel!
    @IBOutlet weak fileprivate var photosCountLabel: UILabel!
    @IBOutlet weak fileprivate var videosCountLabel: UILabel!
    @IBOutlet weak fileprivate var songsCountLabel: UILabel!
    @IBOutlet weak fileprivate var docsCountLabel: UILabel!
    @IBOutlet weak fileprivate var photosMemoryLabel: UILabel!
    @IBOutlet weak fileprivate var videosMemoryLabel: UILabel!
    @IBOutlet weak fileprivate var songsMemoryLabel: UILabel!
    @IBOutlet weak fileprivate var docsMemoryLabel: UILabel!
    @IBOutlet weak fileprivate var pricesTitleLabel: UILabel!
    @IBOutlet weak fileprivate var notesLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var internetDataUsages: [InternetDataUsage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.settingsViewCellUsageInfo)
        setupTableView()
        output.viewIsReady()
    }
    
    private func setupTableView() {
        tableView.register(nibCell: InternetDataUsageCell.self)
    }
    
    @IBAction func actionUpgradeButton(_ sender: UIButton) {
        output.upgradeButtonPressed(with: navigationController)
    }
}

extension UsageInfoViewController: UsageInfoViewInput {
    func display(usage: UsageResponse) {
        photosCountLabel.text = String(format: TextConstants.usageInfoPhotos, usage.imageCount ?? 0)
        photosMemoryLabel.text = (usage.imageUsage ?? 0)?.bytesString
        
        videosCountLabel.text = String(format: TextConstants.usageInfoVideos, usage.videoCount ?? 0)
        videosMemoryLabel.text = (usage.videoUsage ?? 0)?.bytesString
        
        songsCountLabel.text = String(format: TextConstants.usageInfoSongs, usage.audioCount ?? 0)
        songsMemoryLabel.text = (usage.audioUsage ?? 0)?.bytesString
        
        docsCountLabel.text = String(format: TextConstants.usageInfoDocuments, usage.othersCount ?? 0)
        docsMemoryLabel.text = (usage.othersUsage ?? 0)?.bytesString
        
        
        guard let quotaBytes = usage.quotaBytes, let usedBytes = usage.usedBytes else { return }
        memoryUsageProgressView.progress = Float(usedBytes)/Float(quotaBytes)
        
        let quotaString = quotaBytes.bytesString
        let remaindSize = (quotaBytes - usedBytes).bytesString
        memoryUsageLabel.text = String(format: TextConstants.usageInfoBytesRemained, remaindSize, quotaString)
        
        currentPlanLabel.text = String(format: TextConstants.usageInfoWelcome, quotaString)
        
        internetDataUsages = usage.internetDataUsage
        tableView.reloadData()
    }
    
    func display(error: ErrorResponse) {
        
    }
}

extension UsageInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return internetDataUsages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: InternetDataUsageCell.self, for: indexPath)
        cell.fill(with: internetDataUsages[indexPath.row])
        return cell
    }
}
