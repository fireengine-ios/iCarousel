//
//  ReferenceCard.swift
//  Depo
//
//  Created by Alper Kırdök on 26.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class InvitationCard: BaseCardView {

    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var invitationImageView: LoadingImageView!
    @IBOutlet weak var bottomButton: UIButton!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var videoUrl: URL?

    override func configurateView() {
        super.configurateView()

        bottomButton.setTitleColor(UIColor.lrTealish, for: .normal)
        bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)

        bottomButton.setTitle(TextConstants.homeInvitationCardButtn, for: .normal)
        bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        bottomButton.adjustsFontSizeToFitWidth()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = containerStackView.frame.size.height
        if calculatedH != height {
            calculatedH = height
            layoutIfNeeded()
        }
    }

    override func set(object: HomeCardResponse?) {
        super.set(object: object)

        configurateByResponseObject()
    }

    private func configurateByResponseObject() {

        if let videoUrl = cardObject?.details?["videoUrl"].url  {
            playButton.isHidden = false
            self.videoUrl = videoUrl
        }

        if let videoPreviewImageUrl = cardObject?.details?["thumbnail"].url {
            debugLog("Invitation Card - start load image")
            invitationImageView.setLogs(enabled: true)
            invitationImageView.loadImageData(with: videoPreviewImageUrl)
        }
    }

    @IBAction func actionCloseButton(_ sender: Any) {
        deleteCard()
    }

    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .invitation)
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .invitation, eventLabel: .invitation(.close))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.HomepageCard(cardName: NetmeraEventValues.InvitationEventValue.invitation.text, action: NetmeraEventValues.InvitationEventValue.dismiss.text))
    }

    @IBAction func playButtonTapped(_ sender: Any) {

        guard let videoUrl = videoUrl else {
            assertionFailure()
            return
        }

        analyticsService.trackCustomGAEvent(eventCategory: .videoAnalytics, eventActions: .startVideo, eventLabel: .invitation(.invitationVideoButton))

        let player = AVPlayer(url: videoUrl)

        let playerController = FixedAVPlayerViewController()
        playerController.player = player

        let nController = NavigationController(rootViewController: playerController)
        nController.navigationBar.isHidden = true

        RouterVC().presentViewController(controller: nController, animated: true) {
            player.play()
        }
    }

    @IBAction func bottomButtonTapped(_ sender: Any) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .invitation, eventLabel: .invitation(.letsSee))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.HomepageCard(cardName: NetmeraEventValues.InvitationEventValue.invitation.text, action: NetmeraEventValues.InvitationEventValue.detail.text))

        let router = RouterVC()

        let controller = router.invitationController()
        router.pushViewController(viewController: controller)
    }
}
