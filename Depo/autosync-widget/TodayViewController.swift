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
    @IBOutlet private weak var currentImage: UIImageView!
    @IBOutlet private weak var successImage: UIImageView!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let widgetService = WidgetService.shared
    private let mainAppResponsivnessService = AppResponsivenessService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 320, height: 64)
        
        setupWormhole()
        setupTagGesture()
        showAsStopped()
    }
    
    private func setupWormhole() {
        widgetService.wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeMessageIdentifier) { [weak self] messageObject in
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
    
    
    // MARK: Tap handler
    
    @objc private func openApp() {
        if let url = URL(string: SharedConstants.applicationQueriesScheme) {
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
        guard mainAppResponsivnessService.isMainAppResponsive() else {
            showAsStopped()
            return
        }
        
        switch widgetService.syncStatus {
        case .executing :
            showAsExecuting()
        default:
            showAsStopped()
        }
    }
    
    private func showAsExecuting() {
        updateCurrentImage()
        topLabel.text = L10n.widgetTopTitleInProgress
        bottomLabel.text = "\(widgetService.finishedCount) / \(widgetService.totalCount)"
        successImage.isHidden = true
        currentImage.isHidden = false
        activityIndicator.isHidden = (currentImage.image != nil)
        activityIndicator.startAnimating()
    }
    
    private func showAsStopped() {
        if WidgetService.shared.lastSyncedDate.isEmpty {
            topLabel.text = L10n.widgetTopTitleInactive
            bottomLabel.text = L10n.widgetBottomTitleLastSyncFormat(L10n.widgetBottomTitleNewerSyncronized)
        } else {
            topLabel.text = L10n.widgetTopTitleFinished
            bottomLabel.text = L10n.widgetBottomTitleLastSyncFormat(widgetService.lastSyncedDate)
        }
        
        activityIndicator.isHidden = true
        successImage.isHidden = false
        currentImage.isHidden = true
        currentImage.image = nil
        activityIndicator.stopAnimating()
    }
    
    private func updateCurrentImage() {
        let compressedImage = WidgetService.shared.currentCompressedImage
        UIView.transition(with: currentImage,
                          duration: 0.3,
                          options: .transitionCrossDissolve, animations: { self.currentImage.image = compressedImage },
                          completion: nil)
    }
}
