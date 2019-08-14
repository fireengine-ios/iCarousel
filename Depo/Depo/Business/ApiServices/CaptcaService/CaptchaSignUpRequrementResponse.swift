//
//  CaptchaSignUpRequrementResponse.swift
//  Depo
//
//  Created by Aleksandr on 7/12/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class CaptchaSignUpRequirementResponse {
    var captchaRequired = false
    fileprivate let captchaRequiredJsonKey = "captchaRequired"
    
}

extension CaptchaSignUpRequirementResponse: Map {
    convenience init?(json: JSON) {
        self.init()
        
        captchaRequired = json[captchaRequiredJsonKey].boolValue
    }
}
