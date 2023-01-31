//
//  ReferenceCard.swift
//  Depo
//
//  Created by Hady on 14.06.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintCard: BaseCardView {

    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var imageView: LoadingImageView!
    @IBOutlet weak var bottomButton: UIButton!
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var videoUrl: URL?

    override func configurateView() {
        super.configurateView()

        bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
        bottomButton.titleLabel?.font = .appFont(.bold, size: 14)

        bottomButton.setTitle(TextConstants.homePhotoPrintCardButton, for: .normal)
        bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
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
            imageView.setLogs(enabled: true)
            imageView.loadImageData(with: videoPreviewImageUrl)
        }
    }

    @IBAction func actionCloseButton(_ sender: Any) {
        deleteCard()
    }

    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .photoPrint)
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .photoPrint, eventLabel: .homePageCard(.close))
        let event = NetmeraEvents.Actions.HomepageCard(cardName: NetmeraEventValues.HomePageCardEventValue.photoPrint.text, action: NetmeraEventValues.HomePageCardEventValue.dismiss.text)
        AnalyticsService.sendNetmeraEvent(event: event)
    }

    @IBAction func playButtonTapped(_ sender: Any) {

        guard let videoUrl = videoUrl else {
            assertionFailure()
            return
        }

        analyticsService.trackCustomGAEvent(eventCategory: .videoAnalytics, eventActions: .startVideo, eventLabel: .homePageCard(.photoPrintVideoButton))

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
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .photoPrint, eventLabel: .homePageCard(.letsSee))
        let event = NetmeraEvents.Actions.HomepageCard(cardName: NetmeraEventValues.HomePageCardEventValue.photoPrint.text, action: NetmeraEventValues.HomePageCardEventValue.detail.text)
        AnalyticsService.sendNetmeraEvent(event: event)
        NotificationCenter.default.post(name: .photosScreen, object: nil, userInfo: nil)
    }
}
