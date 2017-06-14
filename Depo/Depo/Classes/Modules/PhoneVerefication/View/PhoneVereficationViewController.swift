//
//  PhoneVereficationPhoneVereficationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationViewController: UIViewController, PhoneVereficationViewInput {

    var output: PhoneVereficationViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: PhoneVereficationViewInput
    func setupInitialState() {
    }
}
