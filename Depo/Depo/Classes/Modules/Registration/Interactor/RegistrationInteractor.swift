//
//  RegistrationRegistrationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class RegistrationInteractor: RegistrationInteractorInput {

    weak var output: RegistrationInteractorOutput!
    let dataStorage = DataStorage()
    
    func requestTitle() {
        self.output.pass(title: "butter", forRowIndex: 0)
    }
    
    func prepareModels() {
//        NSString *currentCode;
//        NSString *currentLocale = [Util readLocaleCode];
//        if([currentLocale isEqualToString:@"uk"] || [currentLocale isEqualToString:@"ru"]) {
//            [_countryCodeButton setTitle:@"+90" forState:UIControlStateNormal];
//            currentCode = @"+380";
//            self.selectedCountry = @"UK";
//        } else if ([currentLocale isEqualToString:@"ar"]) {
//            currentCode = @"+966";
//            self.selectedCountry = @"AR";
//        } else if ([currentLocale isEqualToString:@"de"]) {
//            currentCode = @"+49";
//            self.selectedCountry = @"DE";
//        } else {
//            currentCode = @"+90";
//            self.selectedCountry = @"TR";
//        }
        //PREPERes models here and call output
        self.output.prepearedModels(models: dataStorage.getModels())
    }
}
