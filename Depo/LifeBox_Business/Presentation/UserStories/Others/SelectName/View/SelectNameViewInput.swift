//
//  SelectNameSelectNameViewInput.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SelectNameViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    
    func hideView(completion: VoidHandler?)
}
