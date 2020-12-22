//
//  SelectNameSelectNameViewOutput.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SelectNameViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func getTitle() -> String
    
    func getNextButtonText() -> String
    
    func getPlaceholderText() -> String
    
    func getTextForEmptyTextFieldAllert() -> String
    
    func onNextButton(name: String)
}
