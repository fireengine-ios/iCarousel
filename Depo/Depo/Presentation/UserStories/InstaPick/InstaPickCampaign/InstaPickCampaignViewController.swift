//
//  InstaPickCampaignViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/22/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickCampaignViewController: UIViewController, NibInit {
    
    @IBOutlet private var instaPickViewControllerDesigner: InstaPickCampaignViewControllerDesigner!
    
    static func createController() -> InstaPickCampaignViewController {
           let controller = InstaPickCampaignViewController()
           controller.modalTransitionStyle = .crossDissolve
           controller.modalPresentationStyle = .overFullScreen
           return controller
       }
       

    override func viewDidLoad() {
        super.viewDidLoad()


    }


}
