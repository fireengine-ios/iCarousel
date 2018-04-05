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
    @IBOutlet weak private var importFacebookSwitch: UISwitch!
    @IBOutlet weak private var importInstagramSwitch: UISwitch!
    @IBOutlet weak private var importCropySwitch: UISwitch!
    
    @IBOutlet weak private var dropboxButton: UIButton!
    @IBOutlet weak private var dropboxLoaderImageView: RotatingImageView!
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
        dropboxLoadingLabel.text = " "
        
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
    
    func startDropboxStatus() {
        dropboxButton.isEnabled = false
        dropboxLoaderImageView.isHidden = false
        dropboxLoaderImageView.startInfinityRotate360Degrees(duration: 2)
        dropboxLoadingLabel.text = String(format: TextConstants.importFiles, String(0))
    }
    
    func updateDropboxStatus(progressPercent: Int) {
        dropboxLoadingLabel.text = String(format: TextConstants.importFiles, String(progressPercent))
    }
    
    func stopDropboxStatus(lastUpdateMessage: String) {
        dropboxButton.isEnabled = true
        dropboxLoaderImageView.isHidden = true
        dropboxLoaderImageView.stopInfinityRotate360Degrees()
        dropboxLoadingLabel.text = lastUpdateMessage
    }
    
    // MARK: Start
    
    /// nothing. maybe will be toast message
    func dbStartSuccessCallback() {}
    
    func failedDropboxStart(errorMessage: String) {
        let isDropboxAuthorisationError = errorMessage.contains("invalid_access_token") 
        if isDropboxAuthorisationError {
            showErrorAlert(message: TextConstants.dropboxAuthorisationError)
        } else {
            showErrorAlert(message: errorMessage)
        }
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
