//
//  PhoneEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PhoneEnterController: UIViewController, NibInit {
    
    @IBOutlet private var customizator: PhoneEnterCustomizator!
    
//    @IBOutlet private weak var approveButton: UIButton!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction private func actionApproveButton(_ sender: UIButton) {
        print("actionApproveButton")
    }
}
