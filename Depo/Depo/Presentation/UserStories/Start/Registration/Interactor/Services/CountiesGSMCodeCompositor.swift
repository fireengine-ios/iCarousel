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
        var resulArray: [GSMCodeModel] = []
        
        let coreTelephonyService = CoreTelephonyService()
        let countryCodes = coreTelephonyService.callingCodeMap()
        let lifeCountryCodes = coreTelephonyService.lifeOrderedCallingCountryCodes()
        let isoCodes = NSLocale.isoCountryCodes
        let locale = NSLocale(localeIdentifier: Device.supportedLocale)
        
        resulArray = isoCodes.flatMap {
            
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
        
        resulArray = resulArray.sorted(by: { first, second -> Bool in
            if isNeededToShowLifeCountriesFirst {
                switch (lifeCountryCodes.index(of: first.countryCode), lifeCountryCodes.index(of: second.countryCode)) {
                case let (index1, index2) where (index1 != nil && index2 != nil): return index1! < index2!
                case let (index1, _) where index1 != nil: return true
                case let (_, index2) where index2 != nil: return false
                default: break
                }
            }
            return first.countryName < second.countryName
        })

        return resulArray
    }
}
