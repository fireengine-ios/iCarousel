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


final class TodayViewController: UIViewController {
    @IBOutlet private weak var successImage: UIImageView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let widgetService = WidgetService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 320, height: 64)
        
        setupWormhole()
        setupTagGesture()
    }
    
    private func setupWormhole() {
        widgetService.wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeMessageIdentifier) { [weak self] (messageObject) in
            self?.updateFields()
        }
    }
    
    private func setupTagGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openApp))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.isEnabled = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    //MARK: Tap handler
    
    @objc private func openApp() {
        if let url = URL(string: "akillidepo://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
}


extension TodayViewController: NCWidgetProviding {
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        updateFields()
        
        completionHandler(.newData)
    }
    
    private func updateFields() {
        switch widgetService.syncStatus {
        case .executing :
            topLabel.text = TextConstants.widgetTitleInProgress
            bottomLabel.text = "\(widgetService.finishedCount) / \(widgetService.totalCount)"
            activityIndicator.isHidden = false
            successImage.isHidden = true
            activityIndicator.startAnimating()
        default:
            if WidgetService.shared.lastSyncedDate.isEmpty {
                topLabel.text = TextConstants.widgetTitleIsStoped
                bottomLabel.text =  String(format: TextConstants.widgetTitleLastSyncFormat, TextConstants.widgetTitleNeverSynchronized)
            } else {
                topLabel.text = TextConstants.widgetTitleFinished
                bottomLabel.text =  String(format: TextConstants.widgetTitleLastSyncFormat, widgetService.lastSyncedDate)
            }
            
            activityIndicator.isHidden = true
            successImage.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
}


