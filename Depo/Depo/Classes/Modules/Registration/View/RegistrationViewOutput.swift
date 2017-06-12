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

    func prepareCells()
    
    func userInputed(forRow:Int, withValue: String)
//    func isValid(forPhone: String?) -> Bool
//    
//    func getTitle(forIndex index: Int) -> String?
//    func getNumberOfRows() -> Int
//    func getRowHeight(forIndex index: Int) -> CGFloat
    
    func handleNextAction()
    
    func handleTermsAndServices(withNavController navController: UINavigationController)
    
}
