//
//  TermsOfUseInteractorOutput.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


protocol TermsOfUseInteractorOutput: class {
    func showLoaded(eulaHTML: String)
    func failLoadEula(errorString: String)
}
