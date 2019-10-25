//
//  InstaPickCampaignService.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickCampaignServiceDelegate {
    func startActivityIndicator()
    func stopActivityIndicator()
    func continueWithoutCampaign()
}

final class InstaPickCampaignService {
    
    let delegate: InstaPickCampaignServiceDelegate
    let parenViewController: UIViewController
    
    init(viewController: UIViewController, delegate: InstaPickCampaignServiceDelegate) {
        self.parenViewController = viewController
        self.delegate = delegate
    }
    
    private let campaingService = CampaignServiceImpl()
    private let storageVars: StorageVars = factory.resolve()
    private let instapickService: InstapickService = factory.resolve()
    
    private var campaignResponse: CampaignCardResponse?
    
    func chekCampaignParticipation() {
        delegate.startActivityIndicator()
        guard let countryCode = SingletonStorage.shared.accountInfo?.countryCode, countryCode == "90" else {
            delegate.continueWithoutCampaign()
            delegate.stopActivityIndicator()
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
                self.delegate.continueWithoutCampaign()
            }
        }
    }
    
    private func checkDateIsValidForCampaign(response: CampaignCardResponse) {
        let currentDate = Date()
        if response.startDate <= currentDate && currentDate <= response.endDate {
            makeNewAnalysisWithCampaign()
        } else {
            delegate.continueWithoutCampaign()
            delegate.stopActivityIndicator()
        }
    }
    
    private func makeNewAnalysisWithCampaign() {
        delegate.startActivityIndicator()
        instapickService.getAnalyzesCount { [weak self] analizesCountResult in
            switch analizesCountResult {
            case .success(let analizesCountResult):
                self?.handleAnalyzeCountForCamapaign(analizesCountResult: analizesCountResult)
            case .failed(_):
                //MARK: Error handling here
                self?.delegate.stopActivityIndicator()
                break
            }
        }
    }
    
    private func handleAnalyzeCountForCamapaign(analizesCountResult: InstapickAnalyzesCount) {
        switch analizesCountResult {
        case let result where result.isFree == false && result.left == 0:
            prepareInstaPickViewControllerForPresent(with: .withoutLeftPhotoPick)
            
        case let result where result.isFree == true || result.left > 0:
            prepareInstaPickViewControllerForPresent(with: .withLeftPhotoPick)
            
        default:
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
                    //MARK: Error handling here
                    completion(nil)
                }
            }
        }
    }
    
    private func prepareInstaPickViewControllerForPresent(with mode: InstaPickCampaignViewControllerMode) {
        
        getCampaignStatus { [weak self] campaignCardResponse in
            guard let response = campaignCardResponse else {
                //MARK: Error handling will be here
                self?.delegate.stopActivityIndicator()
                return
            }
            
            switch mode {
            case .withLeftPhotoPick:
                self?.handleWithoutLeftPhotoPick(mode: mode, with: response)
            case .withoutLeftPhotoPick:
                self?.presentInstaPickController(mode: mode, with: response)
            }
        }
    }
    
    private func handleWithoutLeftPhotoPick(mode: InstaPickCampaignViewControllerMode, with data: CampaignCardResponse) {
        
        delegate.stopActivityIndicator()
        switch data.dailyRemaining {
        case 0:
            let calendar =  Calendar.current
            if let date = storageVars.shownCampaignInstaPick, calendar.isDateInToday(date) {
                delegate.continueWithoutCampaign()
            } else {
                storageVars.shownCampaignInstaPick = Date()
                presentInstaPickController(mode: mode, with: data)
            }
        case 1...:
            presentInstaPickController(mode: mode, with: data)
        default:
            assertionFailure()
        }
    }
    
    private func presentInstaPickController(mode: InstaPickCampaignViewControllerMode, with data: CampaignCardResponse) {
        delegate.stopActivityIndicator()
        
        let router = RouterVC()
        let controller = InstaPickCampaignViewController.createController(controllerMode: mode,
                                                                          with: data,
                                                                          delegate: self)
        let navController = router.createRootNavigationControllerWithModalStyle(controller: controller)
        router.presentViewController(controller: navController)
    }
}

extension InstaPickCampaignService: InstaPickCampaignViewControllerDelegate {
    func showResultButtonTapped() {
        print("Button tapped")
    }
}
