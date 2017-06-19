//
//  RegistrationRegistrationViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol RegistrationViewOutput {

    /**
        @author AlexanderP
        Notify presenter that view is ready
    */

    func viewIsReady()

    func readyForPassing(withNavController navController: UINavigationController)
//    func nextButtonPressed(withNavController navController: UINavigationController, email: String, phone: String, password: String, repassword: String)
    
    func nextButtonPressed()
    func collectedUserInfo(email: String, phone: String, password: String, repassword: String)
}
