//
//  FaceImageViewController.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

/// on stop NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
final class FaceImageViewController: ViewController, NibInit {
    
    @IBOutlet private var displayManager: FaceImageDisplayManager!
    @IBOutlet private weak var faceImageAllowedLabel: UILabel!
    @IBOutlet private weak var faceImageAllowedSwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()
    private lazy var accountService = AccountService()
    private lazy var analyticsManager: AnalyticsService = factory.resolve()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayManager.applyConfiguration(.initial)
        faceImageAllowedLabel.text = TextConstants.faceImageGrouping
        
        setTitle(withString: TextConstants.faceAndImageGrouping)
        navigationController?.navigationItem.title = TextConstants.backTitle
        
        activityManager.delegate = self
        
        analyticsManager.trackScreen(self)
        
        checkFaceImageIsAllowed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    @IBAction private func faceImageSwitchValueChanged(_ sender: UISwitch) {
        changeFaceImageAllowed(isAllowed: sender.isOn)
    }
    
    @IBAction private func facebookSwitchValueChanged(_ sender: UISwitch) {
        
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
    
    private func changeFaceImageAllowed(isAllowed: Bool) {
        activityManager.start()
        accountService.changeFaceImageAllowed(isAllowed: isAllowed) { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
                    self?.sendAnaliticsForFaceImageAllowed(isAllowed: isAllowed)
                    
                    if isAllowed {
                        let popUp = PopUpController.with(title: nil, message: TextConstants.faceImageWaitAlbum, image: .none, buttonTitle: TextConstants.ok)
                        RouterVC().presentViewController(controller: popUp)
                    }
                    
//                    self?.displayManager.applyConfiguration(.initial)
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                    
                    /// revert state
                    if let isOn = self?.faceImageAllowedSwitch.isOn {
                        self?.faceImageAllowedSwitch.isOn = !isOn
                    }
                }
                self?.stopActivityIndicator()
            }
        }
    }
    
    private func checkFaceImageIsAllowed()  {
        activityManager.start()
        accountService.isAllowedFaceImage { [weak self] result in
            DispatchQueue.toMain {
                switch result {
                case .success(let isAllowed):
                    if isAllowed {
                        
                    } else {
                        self?.displayManager.applyConfiguration(.initial)
                    }
                    
                case .failed(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
                self?.stopActivityIndicator()
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

// --------------------- old ---------------------

final class FaceImageViewController2: ViewController {
    
    var output: FaceImageViewOutput!
    
    @IBOutlet var displayManager: FaceImageDisplayManager!
    @IBOutlet private weak var faceImageAllowedLabel: UILabel!
    @IBOutlet private weak var faceImageAllowedSwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()

    // MARK: - LifeCicle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayManager.applyConfiguration(.initial)
//        displayManager.applyConfiguration(.facebookTagsOff)
//        displayManager.applyConfiguration(.facebookImportOff)
//        displayManager.applyConfiguration(.facebookImportOn)
//        displayManager.applyConfiguration(.initial)
                
        activityManager.delegate = self
        
        faceImageAllowedLabel.text = TextConstants.faceImageGrouping

        configureNavBar()

        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.faceAndImageGrouping)

        navigationController?.navigationItem.title = TextConstants.backTitle
    }
    
    // MARK: UISwitch Action
    
    @IBAction private func faceImageSwitchValueChanged(_ sender: UISwitch) {
        output.changeFaceImageStatus(sender.isOn)
    }
}

// MARK: - ActivityIndicator

extension FaceImageViewController2: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
        activityManager.stop()
    }
}

// MARK: - FaceImageViewInput

extension FaceImageViewController2: FaceImageViewInput {
    func showFaceImageStatus(_ isFaceImageAllowed: Bool) {
        faceImageAllowedSwitch.setOn(isFaceImageAllowed, animated: false)
    }
    
    func showfailedChangeFaceImageStatus() {
        faceImageAllowedSwitch.setOn(!faceImageAllowedSwitch.isOn, animated: true)
    }
}
