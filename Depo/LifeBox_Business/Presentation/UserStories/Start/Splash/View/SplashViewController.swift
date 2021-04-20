//
//  SplashSplashViewController.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SplashViewController: ViewController, NibInit, SplashViewInput, ErrorPresenter {

    var output: SplashViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        output.securityValidation()
    }

    // MARK: SplashViewInput
    func setupInitialState() {
    }
}
