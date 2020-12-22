//
//  SplashSplashViewController.swift
//  Depo
//
//  Created by Oleg on 10/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SplashViewController: ViewController, SplashViewInput, ErrorPresenter {

    var output: SplashViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: SplashViewInput
    func setupInitialState() {
    }
}
