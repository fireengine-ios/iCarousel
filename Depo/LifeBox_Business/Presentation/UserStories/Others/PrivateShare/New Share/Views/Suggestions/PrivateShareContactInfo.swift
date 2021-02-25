//
//  PrivateShareContactInfo.swift
//  Depo
//
//  Created by Konstantin Studilin on 24.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation


struct ContactInfo {
    let name: String
    let value: String
    let identifier: String
    let userType: PrivateShareSubjectType
}


protocol PrivateShareSelectSuggestionsDelegate: class {
    func didSelect(contactInfo: ContactInfo)
    func contactListDidUpdate(isEmpty: Bool)
}

