//
//  COuntiesGSMCodeCompositor.swift
//  Depo
//
//  Created by Aleksandr on 6/13/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class CounrtiesGSMCodeCompositor {
    
    func getGSMCCModels() -> [GSMCodeModel] {
        return self.getLocals()
    }
    
    private func getLocals() -> [GSMCodeModel] {
        var resulArray: [GSMCodeModel] = []
        let coreTelephonyService = CoreTelephonyService()
        
        for isoCode in NSLocale.isoCountryCodes {
            if let phoneCode = coreTelephonyService.callingCodeMap()[isoCode.uppercased()],
               let countryName = (NSLocale.system as NSLocale).displayName(forKey:NSLocale.Key.countryCode,
                                                                           value: isoCode) {
                
                resulArray.append(self.composeModel(withCountryName: countryName,
                                                    phoneCode: phoneCode,
                                                    countryCode: isoCode))
                
            }
        }
        resulArray = resulArray.sorted(by: {$0.0.countryName < $0.1.countryName})
        return resulArray
    }
    
    func composeModel(withCountryName countryName: String, phoneCode: String, countryCode: String) -> GSMCodeModel{
        let model = GSMCodeModel(withCountry: countryName, withCountryCode: countryCode, withGSMCode: phoneCode)
        return model
    }
}
