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
        
        /// start requests
        checkFaceImageIsAllowed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        updateFacebookImportIfNeed()
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
    
    // MARK: - functions
    
    private func updateFacebookImportIfNeed() {
        if displayManager.configuration == .facebookImportOff {
            checkFacebookImportStatus()
        }
    }
    
    private func goToImportPhotos() {
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
    
    private func showFaceImageWaitAlert() {
        let popUp = PopUpController.with(title: nil, message: TextConstants.faceImageWaitAlbum, image: .none, buttonTitle: TextConstants.ok)
        RouterVC().presentViewController(controller: popUp)
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
                        self?.facebookTagsAllowedSwitch.setOn(true, animated: false)
                        self?.showFaceImageWaitAlert()
                        /// next request
                        self?.changeFacebookTagsAllowed(isAllowed: true)
                    } else {
                        self?.displayManager.applyConfiguration(.initial)
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    
                    /// revert state
                    if let isOn = self?.faceImageAllowedSwitch.isOn {
                        self?.faceImageAllowedSwitch.setOn(!isOn, animated: true)
                    }
                }
                self?.activityManager.stop()
                completion?()
            }
        }
    }
    
    private func checkFaceImageIsAllowed(completion: VoidHandler? = nil)  {
        activityManager.start()
        accountService.isAllowedFaceImageAndFacebook { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let result):
                    self?.faceImageAllowedSwitch.setOn(result.isFaceImageAllowed ?? false, animated: true)
//                    if isAllowed {
                        /// next request
//                        self?.checkFacebookTagsIsAllowed(completion: completion)
//                    } else {
//                        self?.displayManager.applyConfiguration(.initial)
                        completion?()
//                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    completion?()
                }
                self?.activityManager.stop()
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
                        /// next request
                        self?.checkFacebookImportStatus(completion: completion)
                    } else {
                        self?.displayManager.applyConfiguration(.facebookTagsOff)
                        completion?()
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    completion?()
                }
                
                self?.activityManager.stop()
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
                        /// next request
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
                self?.activityManager.stop()
            }
        }
    }
    
    private func checkFacebookImportStatus(completion: VoidHandler? = nil) {
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
                self?.activityManager.stop()
                completion?()
            }
        }
    }
}

// MARK: - AnalyticsScreen

extension FaceImageViewController: AnalyticsScreen {
    var analyticsScreen: AnalyticsAppScreens {
        return .settingsFIR
    }
}
