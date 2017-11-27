//
//  OTPViewIO.swift
//  Depo
//
//  Created by Oleg on 12/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol OTPViewInput: class {
    func configurateWithResponce(responce: SignUpSuccessResponse)
}

protocol OTPViewOutput: class {
    func viewIsReady()
}
