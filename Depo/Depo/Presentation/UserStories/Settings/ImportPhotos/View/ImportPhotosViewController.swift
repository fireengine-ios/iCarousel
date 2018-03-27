//
//  ImportPhotosViewController.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ImportPhotosViewController: UIViewController, ErrorPresenter {
    var fbOutput: ImportFromFBViewOutput!
    var dbOutput: ImportFromDropboxViewOutput!
    var instOutput: ImportFromInstagramViewOutput!
    
    @IBOutlet weak private var importDropboxLabel: UILabel!
    @IBOutlet weak private var importFacebookLabel: UILabel!
    @IBOutlet weak private var importInstagramLabel: UILabel!
    @IBOutlet weak private var importCropyLabel: UILabel!
//    @IBOutlet weak private var importDropboxSwitch: UISwitch!
    @IBOutlet weak private var importFacebookSwitch: UISwitch!
    @IBOutlet weak private var importInstagramSwitch: UISwitch!
    @IBOutlet weak private var importCropySwitch: UISwitch!
    
    @IBOutlet weak private var dropboxButton: UIButton!
    @IBOutlet weak private var dropboxLoaderImageView: UIImageView!
    @IBOutlet weak private var dropboxLoadingLabel: UILabel!
    
    private lazy var activityManager = ActivityIndicatorManager()
    
    var isFBConnected: Bool = false {
        didSet {
            importFacebookSwitch.setOn(isFBConnected, animated: true)
        }
    }
    
    var isInstagramConnected: Bool = false {
        didSet {
            importInstagramSwitch.setOn(isInstagramConnected, animated: true)
        }
    }
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropboxLoaderImageView.isHidden = true
        dropboxLoaderImageView.infinityRotate360Degrees()
        
        activityManager.delegate = self
        configureLabels()
        configureSwitches()
        fbOutput.viewIsReady()
        dbOutput.viewIsReady()
        instOutput.viewIsReady()
        
        MenloworksEventsService.shared.onSocialMediaPageOpen()
    }
    
    // MARK: - Helpers
    
    fileprivate func configureLabels() {
        setTitle(withString: TextConstants.importPhotos)
        navigationController?.navigationItem.title = TextConstants.backTitle
        
        importDropboxLabel.text = TextConstants.importFromDB
        importFacebookLabel.text = TextConstants.importFromFB
        importInstagramLabel.text = TextConstants.importFromInstagram
        importCropyLabel.text = TextConstants.importFromCropy
    }
    
    fileprivate func configureSwitches() {
        importCropySwitch.isOn = false
        importCropySwitch.isEnabled = false
    }
    
    // MARK: - IBActions
    
    @IBAction private func actionDropboxButton(_ sender: UIButton) {
        dbOutput.startDropbox()
    }
    
    @IBAction fileprivate func importFromFacebookSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            fbOutput.startFacebook()
        } else {
            fbOutput.stopFacebook()
        }
    }
    
    @IBAction fileprivate func importFromInstagramSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            instOutput.startInstagram()
        } else {
            instOutput.stopInstagram()
        }
    }
    
    @IBAction fileprivate func importFromCropySwitchValueChanged(_ sender: UISwitch) {
        // Coming soon
    }
}

// MARK: - ActivityIndicator
extension ImportPhotosViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

// MARK: - ImportFromFBViewInput
extension ImportPhotosViewController: ImportFromFBViewInput {
    
    func failedFacebookStatus(errorMessage: String) {
        isFBConnected = false
        showErrorAlert(message: errorMessage)
    }
    
    func succeedFacebookStart() {
        MenloworksAppEvents.onFacebookConnected()
        MenloworksEventsService.shared.onFacebookTransfered()
        isFBConnected = true
    }
    
    func failedFacebookStart(errorMessage: String) {
        isFBConnected = false
        showErrorAlert(message: errorMessage)
    }
    
    func succeedFacebookStop() {
        isFBConnected = false
    }
    
    func failedFacebookStop(errorMessage: String) {
        MenloworksAppEvents.onFacebookConnected()
        isFBConnected = true
        showErrorAlert(message: errorMessage)
    }
}

// MARK: - ImportFromDropboxViewInput
extension ImportPhotosViewController: ImportFromDropboxViewInput {
    
    // MARK: Status
    
    func dbStatusSuccessCallback(status: DropboxStatusObject) {
        guard let isConnected = status.connected else {
            return
        }
//        isDBConnected = isConnected
//        
//        if isDBConnected {
//            MenloworksEventsService.shared.onDropboxTransfered()
//        }
        
        ///maybe will be
        //switch status.status {
        //case .finished, .failed, .cancelled:
        //    isDBConnected = false
        //case .running, .pending, .scheduled:
        //    isDBConnected = true
        //case .none, .some(_):
        //   isDBConnected = false
        //}
    }
    
    func dbStatusFailureCallback() {
//        isDBConnected = false
    }
    
    // MARK: Start
    
    /// nothing. maybe will be toast message
    func dbStartSuccessCallback() {}
    
    func failedDropboxStart(errorMessage: String) {
//        isDBConnected = false
        showErrorAlert(message: errorMessage)
    }
}

extension ImportPhotosViewController: ImportFromInstagramViewInput {
    
    // MARK: Status
    
    func instagramStatusSuccess() {
        isInstagramConnected = true
    }
    
    func instagramStatusFailure() {
        isInstagramConnected = false
    }
    
    // MARK: Start
    
    func instagramStartSuccess() {
        MenloworksEventsService.shared.onInstagramTransfered()
        isInstagramConnected = true
    }
    
    func instagramStartFailure(errorMessage: String) {
        isInstagramConnected = false
        showErrorAlert(message: errorMessage)
    }
    
    // MARK: Stop
    
    func instagramStopSuccess() {
        isInstagramConnected = false
    }
    
    func instagramStopFailure(errorMessage: String) {
        isInstagramConnected = true
        showErrorAlert(message: errorMessage)
    }
}
