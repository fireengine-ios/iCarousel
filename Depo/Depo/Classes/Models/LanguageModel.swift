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
    
    let availableLanguageCodes = ["en", "tr", "ar"]

    var languageCode: String?
    var displayLanguage: String?
    var defaultCountryCode: String?
    
    init?(json: JSON){
        if let languageCode = json[LanguageModel.languageCodeKey].string,  self.availableLanguageCodes.contains(languageCode) {
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
    
}
