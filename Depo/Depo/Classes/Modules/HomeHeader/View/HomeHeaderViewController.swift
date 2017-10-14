//
//  HomeHeaderHomeHeaderViewController.swift
//  Depo
//
//  Created by Oleg on 28/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class HomeHeaderViewController: UIViewController, HomeHeaderViewInput {

    var output: HomeHeaderViewOutput!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
    }


    // MARK: HomeHeaderViewInput
    func setupInitialState() {
    }
}
