//
//  InstaPickCampaignService.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickCampaignService {
    
    private lazy var campaingService = CampaignServiceImpl()
    private lazy var instapickService = InstapickServiceImpl()
    private let storageVars: StorageVars = factory.resolve()
    
    private var campaign: PhotopickCampaign?
    private var instaPickCampaignServiceCompletion: ((UINavigationController?, PhotopickCampaign?) -> Void)?

    func getController(completion: @escaping ((UINavigationController?, PhotopickCampaign?) -> Void)) {
        self.instaPickCampaignServiceCompletion = completion
        checkCampaignParticipation()
    }
    
    private func checkCampaignParticipation() {

        guard SingletonStorage.shared.isUserFromTurkey else {
            continueWithCommonFlow()
            return
        }

        campaingService.getPhotopickDetails { [weak self] result in

            guard let self = self else {
                return
            }

            switch result {
            case .success(let response):
                self.campaign = response
                self.checkDateIsValidForCampaign(response: response)
            case .failure(_):
                self.continueWithCommonFlow()
            }
        }
    }
    
    private func checkDateIsValidForCampaign(response: PhotopickCampaign) {
        let currentDate = Date()
        if response.dates.startDate <= currentDate && currentDate <= response.dates.endDate {
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
    
    private func getCampaignStatus(completion: @escaping (PhotopickCampaign?) -> ()) {
        if let response = campaign  {
            completion(response)
        } else {
            campaingService.getPhotopickDetails { result in
                switch result {
                case .success(let success):
                    completion(success)
                case .failure:
                    completion(nil)
                }
            }
        }
    }
    
    private func prepareInstaPickCampaignViewControllerForPresent(with mode: InstaPickCampaignViewControllerMode) {
        getCampaignStatus { [weak self] response in
            guard let response = response else {
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
    
    private func handleWithoutLeftPhotoPick(mode: InstaPickCampaignViewControllerMode, with data: PhotopickCampaign) {
        
        switch data.usage.dailyRemaining {
        case 0:
            let calendar =  Calendar.current
            if let date = storageVars.shownCampaignInstaPickWithoutDaysLeft, calendar.isDateInToday(date) {
                continueWithCommonFlow()
            } else {
                storageVars.shownCampaignInstaPickWithoutDaysLeft = Date()
                returnInstaPickCampaignViewController(mode: mode, with: data)
            }
        case 1...:
            let calendar =  Calendar.current
            if let date = storageVars.shownCampaignInstaPickWithDaysLeft, calendar.isDateInToday(date) {
                continueWithCommonFlow()
            } else {
                storageVars.shownCampaignInstaPickWithDaysLeft = Date()
                returnInstaPickCampaignViewController(mode: mode, with: data)
            }
        default:
            continueWithCommonFlow()
            assertionFailure()
        }
    }
    
    private func returnInstaPickCampaignViewController(mode: InstaPickCampaignViewControllerMode, with data: PhotopickCampaign) {
        
        let router = RouterVC()
        let controller = InstaPickCampaignViewController.createController(controllerMode: mode,
                                                                          with: data)
        let navController = router.createRootNavigationControllerWithModalStyle(controller: controller)
        instaPickCampaignServiceCompletion?(navController, data)
    }
    
    private func continueWithCommonFlow() {
        instaPickCampaignServiceCompletion?(nil, campaign)
    }
}
