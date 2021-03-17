//
//  SettingsSettingsViewOutput.swift
//  Depo
//
//  Created by Oleg on 07/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol SettingsViewOutput {

    func viewIsReady()
    func presentErrorMessage(errorMessage: String)

    func navigateToFAQ()
    func navigateToProfile()
    func navigateToAgreements()
    func navigateToTrashBin()
    func navigateToContactUs()

    func onLogout()
}
