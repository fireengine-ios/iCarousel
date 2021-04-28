//
//  LanguageModel.swift
//  Depo
//
//  Created by Oleg on 05.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import SwiftyJSON

class LanguageModel {
    
    private static let languageCodeKey = "languageCode"
    private static let displayLanguageKey = "displayLanguage"
    private static let defaultCountryCodeKey = "defaultCountryCode"
    
    private static let turkishLanguageDisplayValue = "Türkçe"
    private static let englishLanguageDisplayValue = "English"
    private static let arabicLanguageDisplayValue = "العربية"
    
    let availableLanguageCodes = ["en", "tr", "ar"]

    var languageCode: String?
    var displayLanguage: String?
    var defaultCountryCode: String?
    
    init?(json: JSON) {
        if let languageCode = json[LanguageModel.languageCodeKey].string, self.availableLanguageCodes.contains(languageCode) {
            self.languageCode = languageCode
            displayLanguage = json[LanguageModel.displayLanguageKey].string
            defaultCountryCode = json[LanguageModel.defaultCountryCodeKey].string
        } else {
            return nil
        }
        
    }
    
    init() {
        if let languageCode = Locale.current.languageCode, self.availableLanguageCodes.contains(languageCode) {
            self.languageCode = languageCode
        } else {
            languageCode = availableLanguageCodes.first
        }
    }
    
    init(code: String, displayValue: String, countryCode: String) {
        languageCode = code
        displayLanguage = displayValue
        defaultCountryCode = countryCode
    }
    
    static func availableLanguages() -> [LanguageModel] {
        var result = [LanguageModel]()
        
        result.append(LanguageModel(code: "tr", displayValue: turkishLanguageDisplayValue, countryCode: "90"))
        result.append(LanguageModel(code: "en", displayValue: englishLanguageDisplayValue, countryCode: "1"))
        result.append(LanguageModel(code: "ar", displayValue: arabicLanguageDisplayValue, countryCode: "966"))
        
        return result
    }
    
}
