//
//  FaceImageViewController.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageViewController: UIViewController {
    
    var output: FaceImageViewOutput!
    
    @IBOutlet private weak var faceAllowewLabel: UILabel!
    @IBOutlet private weak var faceAllowewSwitch: UISwitch!
    
    private lazy var activityManager = ActivityIndicatorManager()

    // MARK: - LifeCicle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityManager.delegate = self

        configureNavBar()

        output.viewIsReady()
    }
    
    private func configureNavBar() {
        setTitle(withString: TextConstants.faceAndImageGrouping)

        navigationController?.navigationItem.title = TextConstants.backTitle
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

// MARK: - FaceImageViewInput

extension FaceImageViewController: FaceImageViewInput {
    func showFaceImageStatus(_ isFaceImageAllowed: Bool) {
        faceAllowewSwitch.setOn(isFaceImageAllowed, animated: true)
    }
}
