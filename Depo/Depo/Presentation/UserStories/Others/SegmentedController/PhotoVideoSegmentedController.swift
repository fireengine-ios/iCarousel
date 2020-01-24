//
//  PhotoVideoSegmentedController.swift
//  Depo
//
//  Created by Maxim Soldatov on 11/4/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class PhotoVideoSegmentedController: SegmentedController {
    
    private let instaPickCampaignService = InstaPickCampaignService()
    
    static func initPhotoVideoSegmentedControllerWith(_ controllers: [UIViewController]) -> PhotoVideoSegmentedController {
        let controller = PhotoVideoSegmentedController(nibName: "SegmentedController", bundle: nil)
        controller.setup(with: controllers, alignment: .center)
        return controller
    }
    
    private func handleAnalyzeResultAfterProgressPopUp(analyzesResult: AnalyzeResult) {
        instaPickCampaignService.getController { [weak self] navController in
            DispatchQueue.toMain {
                if let navController = navController,
                    let controller = navController.topViewController as? InstaPickCampaignViewController
                {
                    controller.didClosed = {
                        self?.showResultWithoutCampaign(analyzesCount: analyzesResult.analyzesCount, analysis: analyzesResult.analysis)
                    }
                    self?.hideSpinner()
                    self?.present(navController, animated: true, completion: nil)
                } else {
                    self?.showResultWithoutCampaign(analyzesCount: analyzesResult.analyzesCount, analysis: analyzesResult.analysis)
                }
            }
        }
    }
       
    private func showResultWithoutCampaign(analyzesCount: InstapickAnalyzesCount, analysis: [InstapickAnalyze]) {
        let router = RouterVC()
        let instapickDetailControlller = router.instaPickDetailViewController(models: analysis,
                                                                              analyzesCount: analyzesCount,
                                                                              isShowTabBar: self.isGridRelatedController(controller: router.getViewControllerForPresent()))
        hideSpinner()
        
        present(instapickDetailControlller, animated: true, completion: nil)
    }
       
    private func isGridRelatedController(controller: UIViewController?) -> Bool {
        guard let controller = controller else {
            return false
        }
        return (controller is BaseFilesGreedViewController || controller is SegmentedController)
    }
}

extension PhotoVideoSegmentedController: InstaPickProgressPopupDelegate {
    func analyzeDidComplete(analyzeResult: AnalyzeResult) {
        showSpinner()
        handleAnalyzeResultAfterProgressPopUp(analyzesResult: analyzeResult)
        
        let analysisLeftUserDependent: NetmeraEventValues.PhotopickUserAnalysisLeft
        if analyzeResult.analyzesCount.isFree {
            analysisLeftUserDependent = .premium
        } else {
            analysisLeftUserDependent = .regular(analysisLeft: analyzeResult.analyzesCount.left)
        }
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Photopick(leftAnalysis: analysisLeftUserDependent, status: .success))
    }
    
    func analyzeDidFail() {
        
        let analysisLeftUserDependent: NetmeraEventValues.PhotopickUserAnalysisLeft
        if AuthoritySingleton.shared.accountType.isPremium {
            analysisLeftUserDependent = .premium
        } else {
            analysisLeftUserDependent = .regular(analysisLeft: nil)
        }
              
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Photopick(leftAnalysis: analysisLeftUserDependent, status: .failure))
    }
}
