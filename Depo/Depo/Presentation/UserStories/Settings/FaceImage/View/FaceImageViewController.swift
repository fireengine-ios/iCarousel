//
//  FaceImageViewController.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension Notification.Name {
    public static let changeFaceImageStatus = Notification.Name("changeFaceImageStatus")
}

final class FaceImageViewController: ViewController {
    
    var output: FaceImageViewOutput!
    
    @IBOutlet private weak var faceImageAllowedLabel: UILabel!
    @IBOutlet private weak var faceImageAllowedSwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()

    // MARK: - LifeCicle

    override func viewDidLoad() {
        super.viewDidLoad()
                
        activityManager.delegate = self
        
        faceImageAllowedLabel.text = TextConstants.faceImageGrouping

        configureNavBar()

        output.viewIsReady()
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
