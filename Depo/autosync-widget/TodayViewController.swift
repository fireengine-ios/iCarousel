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


class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 320, height: 64)
        
        setupWormhole()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openApp))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.isEnabled = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        updateFields()
 
        completionHandler(NCUpdateResult.newData)
    }
    
    
    //MARK: - Private
    
    private func updateFields() {
        switch WidgetService.shared.syncStatus {
        case .executing :
            topLabel.text = TextConstants.widgetTitleInProgress
            bottomLabel.text = "\(WidgetService.shared.finishedCount) / \(WidgetService.shared.totalCount)"
            activityIndicator.isHidden = false
            successImage.isHidden = true
            activityIndicator.startAnimating()
        default:
            if WidgetService.shared.lastSyncedDate.isEmpty {
                topLabel.text = TextConstants.widgetTitleIsStoped
                bottomLabel.text =  String.init(format: TextConstants.widgetTitleLastSyncFormat, TextConstants.widgetTitleNeverSynchronized)
            } else {
                topLabel.text = TextConstants.widgetTitleFinished
                bottomLabel.text =  String.init(format: TextConstants.widgetTitleLastSyncFormat, WidgetService.shared.lastSyncedDate)
            }
            
            activityIndicator.isHidden = true
            successImage.isHidden = false
            activityIndicator.stopAnimating()
        }
    }
    
    private func setupWormhole() {
        WidgetService.shared.wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeMessageIdentifier) { [weak self] (messageObject) in
            self?.updateFields()
        }
    }
    
    
    //MARK: Tap handler
    
    @objc private func openApp() {
        if let url = URL(string: "akillidepo://") {
            extensionContext?.open(url, completionHandler: nil)
        }
    }
}


