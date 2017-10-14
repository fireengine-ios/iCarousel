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

    var languageCode: String?
    var displayLanguage: String?
    var defaultCountryCode: String?
    
    init(json: JSON){
        languageCode = json[LanguageModel.languageCodeKey].string
        displayLanguage = json[LanguageModel.displayLanguageKey].string
        defaultCountryCode = json[LanguageModel.defaultCountryCodeKey].string
    }
    
}
