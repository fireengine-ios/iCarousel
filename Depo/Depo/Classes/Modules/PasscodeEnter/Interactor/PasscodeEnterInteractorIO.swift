//
//  PasscodeEnterInteractorIO.swift
//  Depo
//
//  Created by Yaroslav Bondar on 02/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PasscodeEnterInteractorInput: class {
    func isEqual(to passcode: String) -> Bool
    func save(passcode: String)
}

protocol PasscodeEnterInteractorOutput: class {

}
