//
//  TodayViewController.swift
//  autosync-widget
//
//  Created by Konstantin on 2/7/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import NotificationCenter
import MMWormhole

//FIXME: all text constants

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var totalCount = 0
    var finishedCount = 0
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 320, height: 72)
        
        topLabel.text = TextConstants.widgetTitleFinished
        bottomLabel.text = "-- / --";
        
        setupWormhole()
        
        let tapGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(routeToTheApp))
        tapGestureRecognizer.isEnabled = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let defaults = UserDefaults(suiteName: "GROUP_NAME_SUITE_NSUSERDEFAULTS") else {
            completionHandler(NCUpdateResult.noData)
            return
        }
        
        totalCount = defaults.integer(forKey: "totalAutoSyncCount")
        finishedCount = defaults.integer(forKey: "finishedAutoSyncCount")
        
        updateFields()
        
        // If an error is encountered, use NCUpdateResult.failed
        // If there's no update required, use NCUpdateResult.noData
        // If there's an update, use NCUpdateResult.newData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateFields() {
        if finishedCount == totalCount {
            let defaults = UserDefaults.init(suiteName: "GROUP_NAME_SUITE_NSUSERDEFAULTS")
            let lastSyncDateInReadableFormat = defaults?.string(forKey: "lastSyncDate")
            
            topLabel.text = TextConstants.widgetTitleFinished
            bottomLabel.text = lastSyncDateInReadableFormat
            
            activityIndicator.isHidden = true
            successImage.isHidden = false
            
        } else {
            topLabel.text = TextConstants.widgetTitleInProgress
            bottomLabel.text = "\(finishedCount + 1) / \(totalCount)"
            activityIndicator.isHidden = false
            successImage.isHidden = true
            activityIndicator.startAnimating()
        }
    }
    
    private func setupWormhole() {
        let wormhole = MMWormhole(applicationGroupIdentifier: "group.com.turkcell.akillidepo", optionalDirectory: "EXTENSION_WORMHOLE_DIR")
        
        wormhole.listenForMessage(withIdentifier: "EXTENSION_WORMHOLE_TOTAL_COUNT_IDENTIFIER") { [weak self] (messageObject) in
            if let messageObject = messageObject as? Int {
                self?.totalCount = messageObject
                self?.updateFields()
            }
        }
        
        wormhole.listenForMessage(withIdentifier: "EXTENSION_WORMHOLE_FINISHED_COUNT_IDENTIFIER") { [weak self] (messageObject) in
            if let messageObject = messageObject as? Int {
                self?.finishedCount = messageObject
                self?.updateFields()
            }
        }
    }
}


//MARK: - Action handlers

extension TodayViewController {
    @objc private func routeToTheApp() {
        if let url = URL(string: "akillidepo://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
}



