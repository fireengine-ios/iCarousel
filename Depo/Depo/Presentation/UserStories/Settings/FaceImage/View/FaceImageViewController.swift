//
//  FaceImageViewController.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageViewController: ViewController {
    
    var output: FaceImageViewOutput!
    
    @IBOutlet var displayManager: FaceImageDisplayManager!
    @IBOutlet private weak var faceImageAllowedLabel: UILabel!
    @IBOutlet private weak var faceImageAllowedSwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()

    // MARK: - LifeCicle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayManager.applyConfiguration(.initial)
        displayManager.applyConfiguration(.facebookTagsOff)
        displayManager.applyConfiguration(.facebookImportOff)
        displayManager.applyConfiguration(.facebookImportOn)
        displayManager.applyConfiguration(.initial)
                
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

extension FaceImageViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        NotificationCenter.default.post(name: .changeFaceImageStatus, object: self)
        activityManager.stop()
    }
}

// MARK: - FaceImageViewInput

extension FaceImageViewController: FaceImageViewInput {
    func showFaceImageStatus(_ isFaceImageAllowed: Bool) {
        faceImageAllowedSwitch.setOn(isFaceImageAllowed, animated: false)
    }
    
    func showfailedChangeFaceImageStatus() {
        faceImageAllowedSwitch.setOn(!faceImageAllowedSwitch.isOn, animated: true)
    }
}
