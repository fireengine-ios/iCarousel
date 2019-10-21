//
//  CampaignCard.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CampaignCard: BaseView, ControlTabBarProtocol {
    
    private enum UserStatus {
        case backendMode
        //Another cases for Client Mode
        case newUser
        case experiencedUser
        case daylyLimitReached
        case another
    }
    
    @IBOutlet private weak var campaignCardDesigner: CampaignCardDesigner!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel! 
    @IBOutlet private weak var imageView: LoadingImageView!
    @IBOutlet private weak var campaignDetailButton: UIButton!
    @IBOutlet private weak var analyzeDetailButton: UIButton!
   
    private var detailUrl: URL?
    private var userStatus: UserStatus?
    private lazy var router = RouterVC()
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        guard
            let details = object?.details,
            let model = CampaignCardResponse.init(json: details)
        else {
            assertionFailure()
            return
        }
        setupCardView(campaignCardResponse: model)
    }
    
    private func setupCardView(campaignCardResponse: CampaignCardResponse) {
        
        switch campaignCardResponse.messageType {
        case .backend:
            userStatus = .backendMode
            analyzeDetailButton.isHidden = true
            titleLabel.text = campaignCardResponse.title
            descriptionLabel.text = campaignCardResponse.message
        case .client:
            setUserStausForClientMode(totalUsed: campaignCardResponse.totalUsed,
                                      dailyUsed: campaignCardResponse.dailyUsed,
                                      dailyRemaining: campaignCardResponse.dailyRemaining)
            titleLabel.text = TextConstants.campaignCardTitle
            setDescriptionLabelForClientMode(dailyLimit: campaignCardResponse.maxDailyLimit,
                                             totalUsed: campaignCardResponse.totalUsed)
        }
        
        detailUrl = campaignCardResponse.detailsUrl
        imageView.loadImage(url: campaignCardResponse.imageUrl)
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .campaignCard, serverObject: cardObject)
    }
    
    private func presentWebViewWithDetail(with url: URL?) {
        guard let url = url else {
            assertionFailure()
            return
        }
        hideTabBar()
        let vc = WebViewController(urlString: url.absoluteString)
        RouterVC().pushViewController(viewController: vc)
    }
    
    private func setUserStausForClientMode(totalUsed: Int, dailyUsed: Int, dailyRemaining: Int) {
        if totalUsed == 0 {
            userStatus = .newUser
        } else if dailyUsed == 0 && totalUsed > 0 {
            userStatus = .experiencedUser
        } else if dailyRemaining == 0 {
            userStatus = .daylyLimitReached
        } else {
            userStatus = .another
        }
    }
    
    private func setDescriptionLabelForClientMode(dailyLimit: Int, totalUsed: Int) {
        
        switch userStatus {
        case .newUser:
            descriptionLabel.text = TextConstants.campaignCardDescriptionLabelNewUser
        case .experiencedUser:
            descriptionLabel.text = String(format: TextConstants.campaignCardDescriptionLabelExperiencedUser, dailyLimit)
        case .daylyLimitReached:
            descriptionLabel.text = TextConstants.campaignCardDescriptionLabelDaylyLimiReached
        case .another:
            descriptionLabel.text = String(format: TextConstants.campaignCardDescriptionLabelAnother, totalUsed)
        default:
            assertionFailure()
        }
    }
    
    @IBAction private func closeButton(_ sender: Any) {
        deleteCard()
    }
    
    @IBAction private func analyzePhotoPickButton(_ sender: Any) {
        if userStatus == .backendMode {
            assertionFailure()
        } else {
            openPhotopickHistoryPage()
        }
    }
    
    @IBAction private func campaignDetailButton(_ sender: Any) {
        if userStatus == .backendMode {
            presentWebViewWithDetail(with: detailUrl)
        } else {
            openCampaignDetailsPage()
        }
    }
    
    private func openCampaignDetailsPage() {
        let controller = router.campaignDetailViewController()
        router.pushViewController(viewController: controller)
    }

    private func openPhotopickHistoryPage() {
        let controller = router.analyzesHistoryController()
        router.pushViewController(viewController: controller)
    }
}

