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
        return getLocals()
    }
    
    private func getLocals() -> [GSMCodeModel] {
        var resultArray: [GSMCodeModel] = []
        
        let coreTelephonyService = CoreTelephonyService()
        let countryCodes = coreTelephonyService.callingCodeMap()
        let lifeCountryCodes = coreTelephonyService.lifeOrderedCallingCountryCodes()
        let isoCodes = NSLocale.isoCountryCodes
        let locale = NSLocale(localeIdentifier: Device.supportedLocale)
        
        resultArray = isoCodes.compactMap {
            
            let countryCode: String = $0
            let contryName = locale.displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
            guard let phoneCode = countryCodes[countryCode.uppercased()],
                  let unwrapedcontryName = contryName
            else {
                return nil
            }
            
            return GSMCodeModel(withCountry: unwrapedcontryName,
                                withCountryCode: countryCode,
                                withGSMCode: phoneCode)
        }
        
        let isNeededToShowLifeCountriesFirst = (Device.locale == "ru")
        
        resultArray = resultArray.sorted(by: { first, second -> Bool in
            return first.countryName < second.countryName
        })
        
        if isNeededToShowLifeCountriesFirst {
            ///put 'life' countries at the top of the result array
            var gsmModels = [GSMCodeModel]()
            for countryCode in lifeCountryCodes {
                if let index = resultArray.firstIndex(where: { $0.countryCode == countryCode }) {
                    let model = resultArray.remove(at: index)
                    gsmModels.append(model)
                }
            }
            resultArray = gsmModels + resultArray
        }

        return resultArray
    }
}
