//
//  TermsEULAResponse.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class TermsEULAResponse {
    var contentOut: String?
    fileprivate let content = "content"
}

extension TermsEULAResponse: Map {
    convenience init?(json: JSON) {
        self.init()
        contentOut = json[content].stringValue
    }
}
