//
//  WiFiSyncWiFiSyncPresenter.swift
//  Depo
//
//  Created by Oleg on 26/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class WiFiSyncPresenter: WiFiSyncModuleInput, WiFiSyncViewOutput, WiFiSyncInteractorOutput {

    weak var view: WiFiSyncViewInput!
    var interactor: WiFiSyncInteractorInput!
    var router: WiFiSyncRouterInput!

    func viewIsReady() {

    }
    
    func onSyncDataButton(){
        interactor.onSyncDataButton()
    }
    
}
