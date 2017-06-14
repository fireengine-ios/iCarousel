//
//  RegistrationRegistrationViewInput.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol RegistrationViewInput: class {

    /**
        @author AlexanderP
        Setup initial state of the view
    */

    func setupInitialState(withModels: [BaseCellModel])

//    func validationResults(forRow: Int, withValue: String, result: NSError?)
    
    func setupPicker(withModels: [GSMCodeModel])
    
    func prepareNavController()
    
//    func setupRow(forRowIdex rowIndex: Int, withTitle title: String)
}
