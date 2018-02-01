//
//  COuntiesGSMCodeCompositor.swift
//  Depo
//
//  Created by Aleksandr on 6/13/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class CounrtiesGSMCodeCompositor {
    
    private let supportedLanguages = ["tr","en","ua","ru","de","ar","ro","es"]
    private let defaultLanguage = "en"
    
    func getGSMCCModels() -> [GSMCodeModel] {
        return getLocals()
    }
    
    private func getLocals() -> [GSMCodeModel] {
        var resulArray: [GSMCodeModel] = []
        
        let coreTelephonyService = CoreTelephonyService()
        let countryCodes = coreTelephonyService.callingCodeMap()
        let isoCodes = NSLocale.isoCountryCodes
        let locale = NSLocale(localeIdentifier: preferredLanguage())
        
        resulArray = isoCodes.flatMap {
            
            let countryCode: String = $0
            let contryName = locale.displayName(forKey:NSLocale.Key.countryCode, value: countryCode)
            guard let phoneCode = countryCodes[countryCode.uppercased()],
                  let unwrapedcontryName = contryName
            else {
                return nil
            }
            return GSMCodeModel(withCountry: unwrapedcontryName,
                                withCountryCode: countryCode,
                                withGSMCode: phoneCode)
        }
        
        resulArray = resulArray.sorted(by: { (firt, second) -> Bool in
            return firt.countryName < second.countryName
        })
        
        return resulArray
    }
    
    private func preferredLanguage() -> String {
        let preferredLanguages = Locale.preferredLanguages.flatMap {$0.components(separatedBy: "-").first?.lowercased()}
        return preferredLanguages.first(where: {supportedLanguages.contains($0)}) ?? defaultLanguage
    }

}
