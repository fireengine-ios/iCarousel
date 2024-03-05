//
//  DrawCampaignInteractor.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class DrawCampaignInteractor {
    
    var output: DrawCampaignInteractorOutput!
    private let service = DrawCampaignService()
    
    func campaignStatus(campaignId: Int) {
        service.getCampaignStatus(campaignId: campaignId) { [weak self] result in
            switch result {
            case .success(let response):
                self?.output.successCampaignStatus(status: response.result ?? .notAllowed)
            case .failed(let error):
                self?.output.failCampaignStatus(error: error.description)
            }
        }
    }
    
    func campaignPolicy(campaignId: Int) {
        service.getCampaignPolicy(campaignId: campaignId) { [weak self] result in
            switch result {
            case .success(let response):
                self?.output.successCampaignPolicy(response: response)
            case .failed(let error):
                self?.output.failCampaignPolicy(error: error.description)
            }
        }
    }
    
    func campaignApply(campaignId: Int) {
        service.setCampaignApply(campaignId: campaignId) { [weak self] result in
            switch result {
            case .success(let response):
                self?.output.successCampaignApply(response: response)
            case .failed(let error):
                self?.output.failCampaignPolicy(error: error.description)
            }
        }
    }
   
}

extension DrawCampaignInteractor: DrawCampaignInteractorInput {
    func getCampaignStatus(campaignId: Int) {
        campaignStatus(campaignId: campaignId)
    }
    
    func getCampaignPolicy(campaignId: Int) {
        campaignPolicy(campaignId: campaignId)
    }
    
    func setCampaignApply(campaignId: Int) {
        campaignApply(campaignId: campaignId)
    }
}
