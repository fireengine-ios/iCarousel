//
//  ImportPhotosViewController.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ImportPhotosViewController: UIViewController {
    var fbOutput: ImportFromFBViewOutput!
    var dbOutput: ImportFromDropboxViewOutput!
    var instOutput: ImportFromInstagramViewOutput!
    
    @IBOutlet weak fileprivate var importDropboxLabel: UILabel!
    @IBOutlet weak fileprivate var importFacebookLabel: UILabel!
    @IBOutlet weak fileprivate var importInstagramLabel: UILabel!
    @IBOutlet weak fileprivate var importCropyLabel: UILabel!
    @IBOutlet weak fileprivate var importDropboxSwitch: UISwitch!
    @IBOutlet weak fileprivate var importFacebookSwitch: UISwitch!
    @IBOutlet weak fileprivate var importInstagramSwitch: UISwitch!
    @IBOutlet weak fileprivate var importCropySwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()
    
    var isFBConnected: Bool = false {
        didSet {
            importFacebookSwitch.setOn(isFBConnected, animated: true)
        }
    }
    
    var isDBConnected: Bool = false {
        didSet {
            importDropboxSwitch.setOn(isDBConnected, animated: true)
        }
    }
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityManager.delegate = self
        configureLabels()
        configureSwitches()
        fbOutput.viewIsReady()
        dbOutput.viewIsReady()
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
    
    @IBAction fileprivate func importFromDropboxSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            dbOutput.startDropbox()
        } else {
            /// nothing here
        }
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
//            fbOutput.startFacebook()
        } else {
//            fbOutput.stopFacebook()
        }
        // Coming soon
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
        print(errorMessage)
    }
    
    func succeedFacebookStart() {
        isFBConnected = true
    }
    
    func failedFacebookStart(errorMessage: String) {
        isFBConnected = false
        print(errorMessage)
    }
    
    func succeedFacebookStop() {
        isFBConnected = false
    }
    
    func failedFacebookStop(errorMessage: String) {
        isFBConnected = true
        print(errorMessage)
    }
}

// MARK: - ImportFromDropboxViewInput
extension ImportPhotosViewController: ImportFromDropboxViewInput {
    
    // MARK: Status
    
    func dbStatusSuccessCallback(status: DropboxStatusObject) {
        guard let isConnected = status.connected else {
            return
        }
        isDBConnected = isConnected
        
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
        isDBConnected = false
    }
    
    // MARK: Start
    
    /// nothing. maybe will be toast message
    func dbStartSuccessCallback() {}
    
    func failedDropboxStart(errorMessage: String) {
        isDBConnected = false
        print(errorMessage)
    }
}

extension ImportPhotosViewController: ImportFromInstagramViewInput {
    
}
