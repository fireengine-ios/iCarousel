//
//  RegistrationRegistrationInitializer.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class RegistrationModuleInitializer: NSObject {

    //Connect with object on storyboard
    @IBOutlet weak var registrationViewController: RegistrationViewController!

    override init() {
        super.init()
    }
    
    func setupVC() {
        let configurator = RegistrationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: registrationViewController)
        
    }
    
    func setupVC(with user: GoogleUser) {
        let configurator = RegistrationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: registrationViewController, user: user)
    }
    
    init(withNavController navController: UINavigationBar) {
        //add nav controller
    }
    
    override func awakeFromNib() {

        let configurator = RegistrationModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: registrationViewController)
    }

}
