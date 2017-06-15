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
//        let localsArray =
        return self.getLocals()
    }
    
    private func getLocals() -> [GSMCodeModel] {
        var resulArray: [GSMCodeModel] = []
        let filePath = Bundle.main.path(forResource: "countryiso", ofType: "json")
        let pathURL = URL(fileURLWithPath: filePath!)

        guard let jsonData = try? Data(contentsOf: pathURL), let countyIsoPhone = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] else {
         return []
        }
        for isoCode in NSLocale.isoCountryCodes {
            if let phoneCode = countyIsoPhone?[isoCode.uppercased()] as? String,
                let countryName = (NSLocale.system as NSLocale).displayName(forKey:NSLocale.Key.countryCode, value: isoCode) {
                
                resulArray.append(self.composeModel(withCountryName: countryName, phoneCode: phoneCode, countryCode: isoCode))
                
            }
        }
        return resulArray
    }
    
    func composeModel(withCountryName countryName: String, phoneCode: String, countryCode: String) -> GSMCodeModel{
        let model = GSMCodeModel()
        model.countryName = countryName
        model.countryCode = countryCode
        model.code = phoneCode
        return model
    }
}
