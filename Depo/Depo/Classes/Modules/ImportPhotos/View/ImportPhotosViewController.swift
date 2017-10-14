//
//  ImportPhotosViewController.swift
//  Depo
//
//  Created by Maksim Rahleev on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit
import FBSDKLoginKit

private let kImportFromFBEnabled = "kImportFromFBEnabled"
private let kImportFromDBEnabled = "kImportFromDBEnabled"

class ImportPhotosViewController: UIViewController {
    @IBOutlet weak fileprivate var importDropboxLabel: UILabel!
    @IBOutlet weak fileprivate var importFacebookLabel: UILabel!
    @IBOutlet weak fileprivate var importInstagramLabel: UILabel!
    @IBOutlet weak fileprivate var importCropyLabel: UILabel!
    @IBOutlet weak fileprivate var importDropboxSwitch: UISwitch!
    @IBOutlet weak fileprivate var importFacebookSwitch: UISwitch!
    @IBOutlet weak fileprivate var importInstagramSwitch: UISwitch!
    @IBOutlet weak fileprivate var importCropySwitch: UISwitch!
    
    var fbOutput: ImportFromFBViewOutput!
    var dbOutput: ImportFromDropboxViewOutput!
    var accountInfoClient: DBRestClient!

    let defaultPermissions = ["public_profile", "user_photos", "user_videos", "user_birthday"]
    
    var isFBConnected: Bool {
        get {
           return UserDefaults.standard.bool(forKey: kImportFromFBEnabled)
        } set {
            importFacebookSwitch.isOn = newValue
            UserDefaults.standard.set(newValue, forKey: kImportFromFBEnabled)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isDBConnected: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kImportFromDBEnabled)
        } set {
            importDropboxSwitch.isOn = newValue
            UserDefaults.standard.set(newValue, forKey: kImportFromDBEnabled)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        subscribeToNotifications()
    }
    
    // MARK: - Helpers
    
    fileprivate func configureLayout() {
        title = "Import Photos"
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.title = TextConstants.backTitle
        
        configureLabels()
        
        configureSwitches()
    }
    
    fileprivate func configureLabels() {
        importDropboxLabel.text = TextConstants.importFromDB
        importFacebookLabel.text = TextConstants.importFromFB
        importInstagramLabel.text = TextConstants.importFromInstagram
        importCropyLabel.text = TextConstants.importFromCropy
    }
    
    fileprivate func configureSwitches() {
        importDropboxSwitch.isOn = isDBConnected
        importFacebookSwitch.isOn = isFBConnected
        
        importInstagramSwitch.isOn = false
        importInstagramSwitch.isEnabled = false
        
        importCropySwitch.isOn = false
        importCropySwitch.isEnabled = false
    }
    
    fileprivate func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dropboxDidLogin),
                                               name: NSNotification.Name(rawValue: "DBDidLogin"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dropboxDidNotLogin),
                                               name: NSNotification.Name(rawValue: "DBDidNotLogin"),
                                               object: nil)
    }
    
    // MARK: - Notifications
    
    @objc func dropboxDidLogin() {
        accountInfoClient = DBRestClient(session: DBSession.shared())
        accountInfoClient.delegate = self
        accountInfoClient.loadAccountInfo()
    }
    
    @objc func dropboxDidNotLogin() {
        importDropboxSwitch.isOn = false
        isDBConnected = false
    }
    
    // MARK: - Facebook
    
    fileprivate func triggerFacebookStart() {
        showSpiner()
        
        fbOutput.requestStatus()
    }
    
    fileprivate func triggerFacebookStop() {
        showSpiner()
        
        FBSDKLoginManager().logOut()
        fbOutput.requestStop()
        
        isFBConnected = false
    }
    
    fileprivate func triggerFacebookLogin(permissions: FBPermissionsObject?) {
        showSpiner()
        
        fbOutput.requestToken(permissions: permissions?.read ?? defaultPermissions)
    }
    
    fileprivate func facebookLogout() {
        FBSDKLoginManager().logOut()
        importFacebookSwitch.isOn = false
    }
    
    // MARK: - IBActions
    
    @IBAction fileprivate func importFromDropboxSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn != isDBConnected {
            if sender.isOn {
                if DBSession.shared().isLinked() == true {
                    dropboxDidLogin()
                } else {
                    DBSession.shared().link(from: self)
                }
            } else {
                DBSession.shared().unlinkAll()
            }
            
            isDBConnected = sender.isOn
        }
    }
    
    @IBAction fileprivate func importFromFacebookSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn != isFBConnected {
            if sender.isOn {
                triggerFacebookStart()
            } else {
                triggerFacebookStop()
            }
        }
    }
    
    @IBAction fileprivate func importFromInstagramSwitchValueChanged(_ sender: UISwitch) {
        // Coming soon
    }
    
    @IBAction fileprivate func importFromCropySwitchValueChanged(_ sender: UISwitch) {
        // Coming soon
    }
}

extension ImportPhotosViewController: ImportFromFBViewInput {
    // permissions
    func fbPermissionsSuccessCallback(permissions: FBPermissionsObject) {
        hideSpiner()
        
        triggerFacebookLogin(permissions: permissions)
    }
    
    func fbPermissionsFailureCallback(errorMessage: String) {
        hideSpiner()
        
        print(errorMessage)
        
        triggerFacebookLogin(permissions: nil)
    }
    
    // token
    func fbTokenSuccessCallback(token: String) {
        fbOutput.requestConnect(withToken: token)
    }
    
    func fbTokenFailureCallback(errorMessage: String) {
        print(errorMessage)
        
        triggerFacebookStop()
    }
    
    // connect
    func fbConnectSuccessCallback() {
        fbOutput.requestStart()
    }
    
    func fbConnectFailureCallback(errorMessage: String) {
        hideSpiner()
        
        FBSDKLoginManager().logOut()
        importFacebookSwitch.isOn = false
        
        print(errorMessage)
    }
    
    // start
    func fbStartSuccessCallback() {
        hideSpiner()
        
        isFBConnected = true
    }
    
    func fbStartFailureCallback(errorMessage: String) {
        hideSpiner()
        
        print(errorMessage)
    }
    
    // stop
    func fbStopSuccessCallback() {
        hideSpiner()
    }
    
    func fbStopFailureCallback(errorMessage: String) {
        hideSpiner()
        
        print(errorMessage)
    }
    
    // status
    func fbStatusSuccessCallback(status: FBStatusObject) {
        if status.connected == true {
            fbOutput.requestStart()
        } else {
            fbOutput.requestPermissions()
        }
    }
    
    func fbStatusFailureCallback(errorMessage: String) {
        hideSpiner()
        
        print(errorMessage)
        
        fbOutput.requestPermissions()
    }
}

extension ImportPhotosViewController: ImportFromDropboxViewInput {
    
    func dbTokenSuccessCallback(token: String) {
        dbOutput.requestConnect(withToken: token)
    }
    
    func dbTokenFailureCallback(errorMassage: String) {
        // error
    }
    
    func dbConnectSuccessCallback() {
        dbOutput.requestStatusForStart()
    }
    
    func dbConnectFailureCallback(errorMassage: String) {
        // error
    }
    
    func dbStatusForStartSuccessCallback(status: DropboxStatusObject) {
        if status.isQuotaValid! {
            dbOutput.requestStart()
        } else {
            // write that all is sync
        }
    }
    
    func dbStatusForStartFaillureCallback(errorMessage: String) {
        // error
        if (DBSession.shared().isLinked()) {
            DBSession.shared().unlinkAll()
        }
    }
    
    func dbStartSuccessCallback() {
        perform(#selector(scheduleStatusQuery), with: nil, afterDelay: 2.0)
    }
    
    func dbStartFailureCallback(errorMessage: String) {
        // error
    }
    
    func dbStatusSuccessCallback(status: DropboxStatusObject) {
        if status.connected == true {
            if (status.status == .finished || status.status == .failed || status.status == .cancelled) {
                // all sync
            }
            if (status.status == .running || status.status == .pending || status.status == .scheduled) {
                // continue sync
                perform(#selector(scheduleStatusQuery), with: nil, afterDelay: 2.0)
            }
        }
    }
    
    func dbStatusFailureCallback(errorMessage: String) {
        // error
        if (DBSession.shared().isLinked()) {
            DBSession.shared().unlinkAll()
        }
    }
    
    @objc func scheduleStatusQuery() {
        dbOutput.requestStatus()
    }
}

extension ImportPhotosViewController: DBRestClientDelegate {
    
    func restClient(_ client: DBRestClient!, loadedAccountInfo info: DBAccountInfo!) {
        if let accountInfo = info {
            let credentials = DBSession.shared().credentialStore(forUserId: accountInfo.userId)
            if let token = credentials?.accessToken {
                print(token)
                dbOutput.requestToken(withCurrentToken: token,
                                      withConsumerKey: (credentials?.consumerKey)!,
                                      withAppSecret: "umjclqg3juoyihd",
                                      withAuthTokenSecret: (credentials?.accessTokenSecret)!)
            }
        }
    }
}
