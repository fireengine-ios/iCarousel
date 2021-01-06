//
//  SelectNameSelectNameInteractorInput.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol SelectNameInteractorInput {
    
    func getTitle() -> String
    
    func getNextButtonText() -> String
    
    func getPlaceholderText() -> String
    
    func getTextForEmptyTextFieldAllert() -> String
    
    func onNextButton(name: String)
}
