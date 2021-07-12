//
//  TermsOfUseViewInput.swift
//  Depo
//
//  Created by Konstantin on 8/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


protocol TermsOfUseViewInput: AnyObject, Waiting {
    func showLoaded(eulaHTML: String)
    func showAlert(with errorString: String)
}
