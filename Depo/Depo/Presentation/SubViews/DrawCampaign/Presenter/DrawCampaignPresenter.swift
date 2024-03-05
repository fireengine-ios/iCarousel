//
//  DrawCampaignPresenter.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class DrawCampaignPresenter {
    var view: DrawCampaignViewInput?
    var interactor: DrawCampaignInteractorInput!
    var router: DrawCampaignRouterInput!
    
}

extension DrawCampaignPresenter: DrawCampaignInteractorOutput {
    func successCampaignStatus(status: CampaignStatus) {
        view?.successCampaignStatus(status: status)
    }
    
    func failCampaignStatus(error: String) {
        view?.failCampaignStatus(error: error)
    }
    
    func successCampaignPolicy(response: CampaignPolicyResponse) {
        view?.successCampaignPolicy(response: response)
    }
    
    func failCampaignPolicy(error: String) {
        view?.failCampaignPolicy(error: error)
    }
    
    func successCampaignApply(response: CampaignApplyResponse) {
        view?.successCampaignApply(response: response)
    }
}

extension DrawCampaignPresenter: DrawCampaignViewOutput {
    func getCampaignStatus(campaignId: Int) {
        interactor.getCampaignStatus(campaignId: campaignId)
    }
    
    func getCampaignPolicy(campaignId: Int) {
        interactor.getCampaignPolicy(campaignId: campaignId)
    }
    
    func setCampaignApply(campaignId: Int) {
        interactor.setCampaignApply(campaignId: campaignId)
    }
}
