//
//  LoginLoginViewInput.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol LoginViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState(array :[BaseCellModel])
    func showCapcha()
    
}
