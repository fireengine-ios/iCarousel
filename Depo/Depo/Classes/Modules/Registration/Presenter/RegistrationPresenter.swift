//
//  RegistrationRegistrationPresenter.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//
import UIKit

class RegistrationPresenter: RegistrationModuleInput, RegistrationViewOutput, RegistrationInteractorOutput {

    weak var view: RegistrationViewInput!
    var interactor: RegistrationInteractorInput!
    var router: RegistrationRouterInput!

    func viewIsReady() {
        //request info here
    }
    
    func prepareCells() {
        self.interactor.prepareModels()
    }
    
    func userInputed(forRow:Int, withValue: String) {
        // VALIDATE INFO FIRST then call validation results
    }
    
    func prepearedModels(models: [BaseCellModel]) {
        self.view.setupInitialState(withModels: models)
    }
    
//    func isValid(forPhone: String?) -> Bool {
//        return true
//    }
//    
//    func getTitle(forIndex index: Int) -> String? {
//        return nil
//    }
//    
//    func getRowHeight(forIndex index: Int) -> CGFloat {
//        return 80
//    }
//    
//    func getNumberOfRows() -> Int {
//        return 5 
//    }
    
    func setupModels(models: [BaseCellModel]) {
        
    }
    
    func pass(title: String, forRowIndex: Int) {
        debugPrint("titile is ", title)
    }
    
    func handleNextAction() {
        //test----
        self.interactor.requestTitle()//for row, now just for test
        //----test
        
        //in actuality - validate all info?
        //send router message to change vc
        self.router.routNextVC()
    }
    
    func handleTermsAndServices(withNavController navController: UINavigationController) {
        self.router.routNextVC(wihtNavigationController: navController)
    }
    
}
