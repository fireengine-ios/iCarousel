//
//  UsageInfoViewController.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class UsageInfoViewController: ViewController {
    var output: UsageInfoViewOutput!
    
    @IBOutlet weak private var memoryUsageProgressView: RoundedProgressView! {
        didSet {
            memoryUsageProgressView.trackTintColor = ColorConstants.lightGrayColor
            memoryUsageProgressView.progressTintColor = ColorConstants.greenColor
            memoryUsageProgressView.progress = 0
        }
    }
    
    @IBOutlet weak private var currentPlanLabel: UILabel! {
        didSet {
            currentPlanLabel.text = TextConstants.usageInfoQuotaInfo
            currentPlanLabel.textColor = ColorConstants.lightText
            currentPlanLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    
    @IBOutlet weak private var memoryUsageLabel: UILabel! {
        didSet {
            memoryUsageLabel.textColor = ColorConstants.textGrayColor
            memoryUsageLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        }
    }
    
    @IBOutlet weak private var photosCountLabel: UILabel!
    @IBOutlet weak private var videosCountLabel: UILabel!
    @IBOutlet weak private var songsCountLabel: UILabel!
    @IBOutlet weak private var docsCountLabel: UILabel!
    @IBOutlet weak private var photosMemoryLabel: UILabel!
    @IBOutlet weak private var videosMemoryLabel: UILabel!
    @IBOutlet weak private var songsMemoryLabel: UILabel!
    @IBOutlet weak private var docsMemoryLabel: UILabel!
    @IBOutlet weak private var pricesTitleLabel: UILabel!
    @IBOutlet weak private var notesLabel: UILabel!
    
    @IBOutlet private weak var upgradeButton: UIButton! {
        didSet {
            upgradeButton.setTitle(TextConstants.settingsUserInfoViewUpgradeButtonText, for: .normal)
        }
    }
    
    @IBOutlet weak private var tableView: ResizableTableView!
    
    private var internetDataUsages: [InternetDataUsage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.settingsViewCellUsageInfo)
        setupTableView()
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
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
        memoryUsageProgressView.progress = 1 - Float(usedBytes) / Float(quotaBytes)
        
        let quotaString = quotaBytes.bytesString
        var remaind = quotaBytes - usedBytes
        if remaind < 0 {
            remaind = 0
        }
        memoryUsageLabel.text = String(format: TextConstants.usageInfoBytesRemained, remaind.bytesString, quotaString)
        
        
        internetDataUsages = usage.internetDataUsage
        tableView.reloadData()
    }
    
    func display(error: ErrorResponse) {
        UIApplication.showErrorAlert(message: error.description)
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
