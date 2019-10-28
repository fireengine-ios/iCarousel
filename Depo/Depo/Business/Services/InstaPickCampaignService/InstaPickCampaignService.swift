//
//  InstaPickCampaignService.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickCampaignService {
    
    private let campaingService = CampaignServiceImpl()
    private let storageVars: StorageVars = factory.resolve()
    private let instapickService: InstapickService = factory.resolve()
    
    private var campaignResponse: CampaignCardResponse?
    private var instaPickCampaignServiceCompletion: ((UINavigationController?) -> Void)?

    func getController(completion: @escaping ((UINavigationController?) -> Void)) {
        self.instaPickCampaignServiceCompletion = completion
        checkCampaignParticipation()
    }
    
    private func checkCampaignParticipation() {

        guard let countryCode = SingletonStorage.shared.accountInfo?.countryCode, countryCode == "90" else {
            continueWithCommonFlow()
            return
        }

        campaingService.getPhotopickDetails { [weak self] result in

            guard let self = self else {
                return
            }

            switch result {
            case .success(let response):
                self.campaignResponse = response
                self.checkDateIsValidForCampaign(response: response)
            case .failure(_):
                self.continueWithCommonFlow()
            }
        }
    }
    
    private func checkDateIsValidForCampaign(response: CampaignCardResponse) {
        let currentDate = Date()
        if response.startDate <= currentDate && currentDate <= response.endDate {
            continueWithCampaignFlow()
        } else {
            continueWithCommonFlow()
        }
    }
    
    private func continueWithCampaignFlow() {
        instapickService.getAnalyzesCount { [weak self] analizesCountResult in
            switch analizesCountResult {
            case .success(let analizesCountResult):
                self?.handleAnalyzeCountForCamapaign(analizesCountResult: analizesCountResult)
            case .failed(_):
                self?.continueWithCommonFlow()
                break
            }
        }
    }
    
    private func handleAnalyzeCountForCamapaign(analizesCountResult: InstapickAnalyzesCount) {
        switch analizesCountResult {
        case let result where result.isFree == false && result.left == 0:
            prepareInstaPickCampaignViewControllerForPresent(with: .withoutLeftPhotoPick)
            
        case let result where result.isFree == true || result.left > 0:
            prepareInstaPickCampaignViewControllerForPresent(with: .withLeftPhotoPick)
            
        default:
            continueWithCommonFlow()
            assertionFailure()
        }
    }
    
    private func getCampaignStatus(completion: @escaping (CampaignCardResponse?) -> ()) {
        if let response = campaignResponse  {
            completion(response)
        } else {
            campaingService.getPhotopickDetails { result in
                switch result {
                case .success(let success):
                    completion(success)
                case .failure(_):
                    completion(nil)
                }
            }
        }
    }
    
    private func prepareInstaPickCampaignViewControllerForPresent(with mode: InstaPickCampaignViewControllerMode) {
        
        getCampaignStatus { [weak self] campaignCardResponse in
            guard let response = campaignCardResponse else {
                self?.continueWithCommonFlow()
                assertionFailure()
                return
            }
            
            switch mode {
            case .withLeftPhotoPick:
                self?.handleWithoutLeftPhotoPick(mode: mode, with: response)
            case .withoutLeftPhotoPick:
                self?.returnInstaPickCampaignViewController(mode: mode, with: response)
            }
        }
    }
    
    private func handleWithoutLeftPhotoPick(mode: InstaPickCampaignViewControllerMode, with data: CampaignCardResponse) {
        
        switch data.dailyRemaining {
        case 0:
            let calendar =  Calendar.current
            if let date = storageVars.shownCampaignInstaPick, calendar.isDateInToday(date) {
                continueWithCommonFlow()
            } else {
                storageVars.shownCampaignInstaPick = Date()
                returnInstaPickCampaignViewController(mode: mode, with: data)
            }
        case 1...:
            returnInstaPickCampaignViewController(mode: mode, with: data)
        default:
            continueWithCommonFlow()
            assertionFailure()
        }
    }
    
    private func returnInstaPickCampaignViewController(mode: InstaPickCampaignViewControllerMode, with data: CampaignCardResponse) {
        
        let router = RouterVC()
        let controller = InstaPickCampaignViewController.createController(controllerMode: mode,
                                                                          with: data)
        let navController = router.createRootNavigationControllerWithModalStyle(controller: controller)
        instaPickCampaignServiceCompletion?(navController)
    }
    
    private func continueWithCommonFlow() {
        instaPickCampaignServiceCompletion?(nil)
    }
}
