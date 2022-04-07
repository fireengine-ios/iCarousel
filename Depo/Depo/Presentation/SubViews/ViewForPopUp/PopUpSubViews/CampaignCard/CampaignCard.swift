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
    
    init(response: PhotopickCampaign) {
        if response.usage.totalUsed == 0 {
            self = .newUser
        } else if response.usage.dailyUsed == 0 && response.usage.totalUsed > 0 {
            self = .experiencedUser
        } else if response.usage.dailyRemaining == 0 {
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

final class CampaignCard: BaseCardView {
    
    @IBOutlet private weak var campaignCardDesigner: CampaignCardDesigner!
    @IBOutlet private weak var titleLabel: UILabel!
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
    private lazy var campaignService = CampaignServiceImpl()

    /// This is set true for the new card that
    /// sets the title from responses below at `setupCardView(campaignCardResponse:)`
    var isPromotion: Bool = false
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        guard
            case let data?? = try? object?.details?.rawData(),
            let model = try? campaignService.getPhotopickDetails(from: data)
        else {
            assertionFailure()
            return
        }
        setupCardView(campaign: model)
    }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          
          let height = contentStackView.frame.size.height
          if calculatedH != height {
              calculatedH = height
              layoutIfNeeded()
          }
      }
    
    private func setupCardView(campaign: PhotopickCampaign) {
        
        switch campaign.content.messageType {
        case .backend:
            userStatus = .backendMode
            analyzeDetailButton.isHidden = true
            titleLabel.text = campaign.content.title
            descriptionLabel.text = campaign.content.message
            campaignDetailButton.setTitle(campaign.content.detailsText, for: .normal)
        case .client:
            titleLabel.text = isPromotion ? campaign.content.title : TextConstants.campaignCardTitle
            userStatus = CampaignUserStatus(response: campaign)
            setDescriptionLabelForClientMode(dailyLimit: campaign.usage.maxDailyLimit,
                                             totalUsed: campaign.usage.totalUsed)
            campaignDetailButton.setTitle(TextConstants.campaignDetailButtonTitle, for: .normal)
        case .unknown:
            break
        }
        
        detailUrl = campaign.detailsURL

        debugLog("Campaign Card - start load image")
        imageView.setLogs(enabled: true)
        imageView.loadImageData(with: URL(string: campaign.imageURL))
        
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

