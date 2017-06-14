//
//  PhoneVereficationPhoneVereficationInitializer.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var phonevereficationViewController: PhoneVereficationViewController!

    override func awakeFromNib() {

        let configurator = PhoneVereficationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: phonevereficationViewController)
    }

}
