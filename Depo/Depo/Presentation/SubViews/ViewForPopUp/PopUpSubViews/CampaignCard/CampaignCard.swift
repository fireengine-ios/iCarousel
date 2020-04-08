//
//  CampaignCard.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/17/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

private enum CampaignUserStatus {
    case backendMode
    //Another cases for Client Mode
    case newUser
    case experiencedUser
    case daylyLimitReached
    case another
    
    init(response: CampaignCardResponse) {
        if response.totalUsed == 0 {
            self = .newUser
        } else if response.dailyUsed == 0 && response.totalUsed > 0 {
            self = .experiencedUser
        } else if response.dailyRemaining == 0 {
            self = .daylyLimitReached
        } else {
            self = .another
        }
    }
    
    var gaEventLabel: GAEventLabel? {
        switch self {
        case .newUser:
            return .campaign(.neverParticipated)
        case .experiencedUser:
            return .campaign(.notParticipated)
        case .daylyLimitReached:
            return .campaign(.limitIsReached)
        case .another:
            return .campaign(.otherwise)
        case .backendMode:
            return nil
        }
    }
}

final class CampaignCard: BaseCardView, ControlTabBarProtocol {
    
    @IBOutlet private weak var campaignCardDesigner: CampaignCardDesigner!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel! 
    @IBOutlet private weak var imageView: LoadingImageView!
    @IBOutlet private weak var campaignDetailButton: UIButton!
    @IBOutlet private weak var analyzeDetailButton: UIButton!
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var playVideoButton: UIButton!
    
    private var detailUrl: String?
    private var videoUrl: URL?
    private var userStatus: CampaignUserStatus?
    private lazy var router = RouterVC()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
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
    
    override func layoutSubviews() {
          super.layoutSubviews()
          
          let height = contentStackView.frame.size.height
          if calculatedH != height {
              calculatedH = height
              layoutIfNeeded()
          }
      }
    
    private func setupCardView(campaignCardResponse: CampaignCardResponse) {
        
        switch campaignCardResponse.messageType {
        case .backend:
            userStatus = .backendMode
            analyzeDetailButton.isHidden = true
            titleLabel.text = campaignCardResponse.title
            descriptionLabel.text = campaignCardResponse.message
            campaignDetailButton.setTitle(campaignCardResponse.detailsText, for: .normal)
        case .client:
            userStatus = CampaignUserStatus(response: campaignCardResponse)
            titleLabel.text = TextConstants.campaignCardTitle
            setDescriptionLabelForClientMode(dailyLimit: campaignCardResponse.maxDailyLimit,
                                             totalUsed: campaignCardResponse.totalUsed)
            campaignDetailButton.setTitle(TextConstants.campaignDetailButtonTitle, for: .normal)
        }
        
        detailUrl = campaignCardResponse.detailsUrl

        debugLog("Campaign Card - start load image")
        imageView.setLogs(enabled: true)
        imageView.loadImageData(with: campaignCardResponse.imageUrl)
        
        //TODO: uncomment when BE wil be ready
//        if let videoUrl = campaignCardResponse.videoUrl {
//            imageView.image = videoUrl.videoPreview
//            self.videoUrl = videoUrl
//            playVideoButton.isHidden = false
//        }
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .campaignCard, serverObject: cardObject)
    }
    
    private func presentWebViewWithDetail(with url: String?) {
        guard let url = url else {
            assertionFailure()
            return
        }
        hideTabBar()
        let vc = WebViewController(urlString: url)
        RouterVC().pushViewController(viewController: vc)
    }
    
    private func setDescriptionLabelForClientMode(dailyLimit: Int, totalUsed: Int) {
        
        switch userStatus {
        case .newUser:
            descriptionLabel.text = TextConstants.campaignCardDescriptionLabelNewUser
        case .experiencedUser:
            descriptionLabel.text = String(format: TextConstants.campaignCardDescriptionLabelExperiencedUser, totalUsed)
        case .daylyLimitReached:
            descriptionLabel.text = String(format: TextConstants.campaignCardDescriptionLabelDaylyLimiReached, totalUsed)
        case .another:
            descriptionLabel.text = String(format: TextConstants.campaignCardDescriptionLabelAnother, totalUsed)
        default:
            assertionFailure()
        }
    }
}
    
//MARK: - Actions

extension CampaignCard {
        
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
    
    @IBAction private func playVideo(_ sender: Any) {
        openVideoController()
    }
}

//MARK: - Routing

extension CampaignCard {
    private func openCampaignDetailsPage() {
        if let eventLabel = userStatus?.gaEventLabel {
            analyticsService.trackCustomGAEvent(eventCategory: .campaign,
                                                eventActions: .campaignDetail,
                                                eventLabel: eventLabel)
        }
        
        let controller = router.campaignDetailViewController()
        router.pushViewController(viewController: controller)
    }

    private func openPhotopickHistoryPage() {
        if let eventLabel = userStatus?.gaEventLabel {
            analyticsService.trackCustomGAEvent(eventCategory: .campaign,
                                                eventActions: .analyzeWithPhotopick,
                                                eventLabel: eventLabel)
        }
        
        let controller = router.analyzesHistoryController()
        router.pushViewController(viewController: controller)
    }
    
    private func openVideoController() {
        guard let videoUrl = videoUrl else {
            return
        }
        
        let player = AVPlayer(url: videoUrl)
        let playerController = FixedAVPlayerViewController()
        playerController.player = player
        router.presentViewController(controller: playerController) {
            player.play()
        }
    }
}

