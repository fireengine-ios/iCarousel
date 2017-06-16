//
//  GSMCodeModel.swift
//  Depo
//
//  Created by Aleksandr on 6/13/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct GSMCodeModel {
    var countryName: String
    var countryCode: String
    var gsmCode: String
    
    init(withCountry country: String, withCountryCode countryCode: String, withGSMCode gsmCode: String) {
        self.countryName = country
        self.countryCode = countryCode
        self.gsmCode = gsmCode
    }
}
