//
//  TermsAndServicesTermsAndServicesViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol TermsAndServicesViewOutput {
    func viewIsReady()
    func startUsing()
    func confirmAgreements(_ confirm: Bool)
    func openTurkcellAndGroupCompanies()
    func openCommercialEmailMessages()
    func confirmEtk(_ etk: Bool)
    func confirmGlobalPerm(_ globalPerm: Bool)
    func openPrivacyPolicyDescriptionController()
}
