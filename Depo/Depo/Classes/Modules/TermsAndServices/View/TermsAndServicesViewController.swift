//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesViewController: UIViewController, TermsAndServicesViewInput {

    var output: TermsAndServicesViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
    }
}
