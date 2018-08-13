//
//  FaceImageViewController.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageViewController: ViewController, NibInit {
    
    @IBOutlet private var displayManager: FaceImageDisplayManager!
    @IBOutlet private var designer: FaceImageDesigner!
    @IBOutlet private weak var faceImageAllowedSwitch: UISwitch!
    @IBOutlet private weak var facebookTagsAllowedSwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()
    private lazy var accountService = AccountService()
    private lazy var analyticsManager: AnalyticsService = factory.resolve()
    private lazy var facebookService = FBService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayManager.applyConfiguration(.initial)
        
        setTitle(withString: TextConstants.faceAndImageGrouping)
        navigationController?.navigationItem.title = TextConstants.backTitle
        
        activityManager.delegate = self
        analyticsManager.trackScreen(self)
        
        checkFaceImageIsAllowed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        
        if displayManager.configuration == .facebookImportOff {
            checkFacebookImportStatus()
        }
    }
    
    @IBAction private func faceImageSwitchValueChanged(_ sender: UISwitch) {
        changeFaceImageAllowed(isAllowed: sender.isOn)
    }
    
    @IBAction private func facebookSwitchValueChanged(_ sender: UISwitch) {
        changeFacebookTagsAllowed(isAllowed: sender.isOn)
    }
    
    @IBAction private func showFacebookImport(_ sender: UIButton) {
        goToImportPhotos()
    }
    
    func goToImportPhotos() {
        let router = RouterVC()
        router.pushViewController(viewController: router.importPhotos!)
    }
    
    private func sendAnaliticsForFaceImageAllowed(isAllowed: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .faceRecognition, eventLabel: .faceRecognition(isAllowed))
        
        MenloworksTagsService.shared.faceImageRecognition(isOn: isAllowed)
        if isAllowed {
            MenloworksEventsService.shared.onFaceImageRecognitionOn()
        } else {
            MenloworksEventsService.shared.onFaceImageRecognitionOff()
        }
    }
    
    // MARK: - face image
    
    private func changeFaceImageAllowed(isAllowed: Bool,  completion: VoidHandler? = nil) {
        activityManager.start()
        accountService.changeFaceImageAllowed(isAllowed: isAllowed) { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
                    self?.sendAnaliticsForFaceImageAllowed(isAllowed: isAllowed)
                    
                    if isAllowed {
                        ///self?.checkFacebookTagsIsAllowed(completion: completion)
                        self?.facebookTagsAllowedSwitch.setOn(true, animated: false)
                        self?.changeFacebookTagsAllowed(isAllowed: true)
                        
                        /// popup
                        let popUp = PopUpController.with(title: nil, message: TextConstants.faceImageWaitAlbum, image: .none, buttonTitle: TextConstants.ok)
                        RouterVC().presentViewController(controller: popUp)
                    } else {
                        self?.displayManager.applyConfiguration(.initial)
                        completion?()
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    
                    /// revert state
                    if let isOn = self?.faceImageAllowedSwitch.isOn {
                        self?.faceImageAllowedSwitch.setOn(!isOn, animated: true)
                    }
                    completion?()
                }
                self?.stopActivityIndicator()
            }
        }
    }
    
    private func checkFaceImageIsAllowed(completion: VoidHandler? = nil)  {
        activityManager.start()
        accountService.isAllowedFaceImage { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let isAllowed):
                    self?.faceImageAllowedSwitch.setOn(isAllowed, animated: true)
                    if isAllowed {
                        /// next check
                        self?.checkFacebookTagsIsAllowed(completion: completion)
                    } else {
                        self?.displayManager.applyConfiguration(.initial)
                        completion?()
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    completion?()
                }
                self?.stopActivityIndicator()
            }
        }
    }
    
    // MARK: - facebook
    
    private func checkFacebookTagsIsAllowed(completion: VoidHandler? = nil)  {
        activityManager.start()
        accountService.isAllowedFacebookTags { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let isAllowed):
                    self?.facebookTagsAllowedSwitch.setOn(isAllowed, animated: true)
                    if isAllowed {
                        self?.checkFacebookImportStatus(completion: completion)
                    } else {
                        self?.displayManager.applyConfiguration(.facebookTagsOff)
                        completion?()
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    completion?()
                }
                self?.stopActivityIndicator()
            }
        }
    }
    
    private func changeFacebookTagsAllowed(isAllowed: Bool, completion: VoidHandler? = nil) {
        activityManager.start()
        
        accountService.changeFacebookTagsAllowed(isAllowed: isAllowed) { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(_):
                    if isAllowed {
                        self?.checkFacebookImportStatus(completion: completion)
                    } else {
                        self?.displayManager.applyConfiguration(.facebookTagsOff)
                        completion?()
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    
                    /// revert state
                    if let isOn = self?.facebookTagsAllowedSwitch.isOn {
                        self?.facebookTagsAllowedSwitch.setOn(!isOn, animated: true)
                    }
                    completion?()
                }
                self?.stopActivityIndicator()
            }
        }
    }
    
    func checkFacebookImportStatus(completion: VoidHandler? = nil) {
        activityManager.start()
        facebookService.requestStatus { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let isAllowed):
                    if isAllowed {
                        self?.displayManager.applyConfiguration(.facebookImportOn)
                    } else {
                        self?.displayManager.applyConfiguration(.facebookImportOff)
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
                self?.stopActivityIndicator()
                completion?()
            }
        }
    }
}

// MARK: - ActivityIndicator

extension FaceImageViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

// MARK: - AnalyticsScreen

extension FaceImageViewController: AnalyticsScreen {
    var analyticsScreen: AnalyticsAppScreens {
        return .settingsFIR
    }
}
