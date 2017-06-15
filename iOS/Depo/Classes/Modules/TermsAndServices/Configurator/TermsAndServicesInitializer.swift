//
//  TermsAndServicesTermsAndServicesInitializer.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var termsandservicesViewController: TermsAndServicesViewController!

    override func awakeFromNib() {

        let configurator = TermsAndServicesModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: termsandservicesViewController)
    }

//    init(withNavigationController navController: UINavigationController) {
//        
//    }

    func setupConfig() {
        let configurator = TermsAndServicesModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: termsandservicesViewController)
    }
    
}
