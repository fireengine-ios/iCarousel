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
    private let authorityStorage = AuthoritySingleton.shared
    
    private var isShowFaceImageWaitAlert: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.faceAndImageGrouping)
        navigationController?.navigationItem.title = TextConstants.backTitle
        
        activityManager.delegate = self
        analyticsManager.trackScreen(self)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayManager.applyConfiguration(authorityStorage.accountType.isPremium ? .initialPremium : .initialStandart) 

        navigationBarWithGradientStyle()
        checkFaceImageAndFacebokIsAllowed()
    }
    
    @IBAction private func faceImageSwitchValueChanged(_ sender: UISwitch) {
        isShowFaceImageWaitAlert = true
        changeFaceImageAndFacebookAllowed(isFaceImageAllowed: sender.isOn, isFacebookAllowed: sender.isOn)
    }
    
    @IBAction private func facebookSwitchValueChanged(_ sender: UISwitch) {
        changeFaceImageAndFacebookAllowed(isFaceImageAllowed: faceImageAllowedSwitch.isOn, isFacebookAllowed: sender.isOn)
    }
    
    @IBAction private func showFacebookImport(_ sender: UIButton) {
        goToConnectedAccounts()
    }
    
    @IBAction private func onPremiumButtonTap(_ sender: Any) {
        goToPremium()
        
    }
    // MARK: - functions
    
    private func updateFacebookImportIfNeed() {
        if displayManager.configuration == .facebookImportOff {
            checkFacebookImportStatus()
        }
    }
    
    private func goToConnectedAccounts() {
        let router = RouterVC()
        router.pushViewController(viewController: router.connectedAccounts!)
    }
    
    private func goToPremium() {
        let router = RouterVC()
        router.pushViewController(viewController: router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember))
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
    private func changeFaceImageAndFacebookAllowed(isFaceImageAllowed: Bool, isFacebookAllowed: Bool, completion: VoidHandler? = nil) {
        activityManager.start()
        accountService.changeFaceImageAndFacebookAllowed(isFaceImageAllowed: isFaceImageAllowed, isFacebookAllowed: isFacebookAllowed) { [weak self] response in
            DispatchQueue.toMain {
                switch response {
                case .success(let result):
                    NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
                    self?.sendAnaliticsForFaceImageAllowed(isAllowed: result.isFaceImageAllowed == true)
                    
                    if result.isFaceImageAllowed == true {
                        if self?.authorityStorage.faceRecognition == false {
                            self?.displayManager.applyConfiguration(.faceImageStandart)
                        } else if self?.faceImageAllowedSwitch.isOn == true {
                            self?.displayManager.applyConfiguration(.faceImagePremium)
                        }
                        
                        if self?.isShowFaceImageWaitAlert == true {
                            self?.showFaceImageWaitAlert()
                        }
                        
                        if result.isFacebookAllowed == true {
                            self?.facebookTagsAllowedSwitch.setOn(true, animated: false)
                            self?.checkFacebookImportStatus()
                        } else {
                            self?.displayManager.applyConfiguration(.facebookTagsOff)
                        }
                    } else {
                        self?.displayManager.applyConfiguration(self?.authorityStorage.accountType.isPremium == true ? .initialPremium : .initialStandart)
                    }
                    
                    self?.view.layoutIfNeeded()
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                        
                        /// revert state
                    self?.facebookTagsAllowedSwitch.setOn(self?.facebookTagsAllowedSwitch.isOn == false, animated: true)
                    self?.faceImageAllowedSwitch.setOn(self?.faceImageAllowedSwitch.isOn == false, animated: true)
                }
                self?.activityManager.stop()
                self?.isShowFaceImageWaitAlert = false
                completion?()
            }
        }
    }
    
    private func checkFaceImageAndFacebokIsAllowed(completion: VoidHandler? = nil)  {
        let group = DispatchGroup()
        activityManager.start()
        checkFaceImageStatus(with: group)
        
        group.notify(queue: .main) {
            self.activityManager.stop()
            if self.authorityStorage.faceRecognition == false, self.faceImageAllowedSwitch.isOn {
                self.displayManager.applyConfiguration(.faceImageStandart)
            } else if self.faceImageAllowedSwitch.isOn {
                self.displayManager.applyConfiguration(.faceImagePremium)
            } else {
                self.displayManager.applyConfiguration(self.authorityStorage.accountType.isPremium ? .initialPremium : .initialStandart)
            }
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    // MARK: - facebook
    private func checkFacebookImportStatus(completion: VoidHandler? = nil, group: DispatchGroup? = nil) {
        if group == nil {
            activityManager.start()
        } else {
            group?.enter()
        }
        
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
                if group == nil {
                    self?.activityManager.stop()
                } else {
                    group?.leave()
                }
                
                completion?()
            }
        }
    }
    
    private func checkFaceImageStatus(with group: DispatchGroup) {
        group.enter()
        
        accountService.permissions { [weak self] response in
            switch response {
            case .success(let result):
                self?.authorityStorage.refreshStatus(with: result)
                
                self?.checkFaceImageAndFacebookState(with: group)
            case .failed(let error):
                DispatchQueue.toMain {
                    UIApplication.showErrorAlert(message: error.description)
                }
                
                self?.checkFaceImageAndFacebookState(with: group)
            }
            
            group.leave()
        }
    }
    
    private func checkFaceImageAndFacebookState(with group: DispatchGroup, completion: VoidHandler? = nil) {
        group.enter()
        
        accountService.getSettingsInfoPermissions { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let result):
                    self?.faceImageAllowedSwitch.setOn(result.isFaceImageAllowed == true, animated: true)
                    self?.facebookTagsAllowedSwitch.setOn(result.isFacebookAllowed == true, animated: true)
                    
                    if result.isFacebookAllowed == true {
                        self?.checkFacebookImportStatus(completion: completion, group: group)
                    } else {
                        self?.displayManager.applyConfiguration(.facebookTagsOff)
                        completion?()
                    }

                    completion?()
                case .failed(let error):
                    DispatchQueue.toMain {
                        /// revert state
                        self?.facebookTagsAllowedSwitch.setOn(self?.facebookTagsAllowedSwitch.isOn == false, animated: true)
                        self?.faceImageAllowedSwitch.setOn(self?.faceImageAllowedSwitch.isOn == false, animated: true)
                        
                        UIApplication.showErrorAlert(message: error.description)
                    }
                    
                    completion?()
                }
            }
            
            group.leave()
        }
    }
}

// MARK: - AnalyticsScreen

extension FaceImageViewController: AnalyticsScreen {
    var analyticsScreen: AnalyticsAppScreens {
        return .settingsFIR
    }
}
