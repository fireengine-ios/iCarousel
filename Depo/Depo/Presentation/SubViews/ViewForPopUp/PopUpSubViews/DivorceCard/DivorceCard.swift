//
//  DivorceCard.swift
//  Depo_LifeTech
//
//  Created by ÜNAL ÖZTÜRK on 12.12.2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class DivorceCard: BaseCardView {
    
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var dividerLineView: UIView!
    @IBOutlet private weak var videoPreviewImageView: LoadingImageView!
    
    private var videoUrl: URL?
    
    override func configurateView() {
        super.configurateView()
        backgroundColor = .white
        canSwipe = false
        
        titleLabel.font = UIFont.TurkcellSaturaFont(size: 18)
        titleLabel.textColor = ColorConstants.darkText
        titleLabel.text = TextConstants.homeDivorceCardTitle
        
        bottomButton.setTitleColor(UIColor.lrTealish, for: .normal)
        bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        
        bottomButton.setTitle(TextConstants.homeLatestUploadsCardAllPhotosButtn, for: .normal)
        bottomButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        bottomButton.adjustsFontSizeToFitWidth()
        
        dividerLineView.isHidden = false
        
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        configurateByResponseObject()
    }
    
    private func configurateByResponseObject() {
        
        if let videoUrl = cardObject?.details?["videoUrl"].url,
            let videoPreviewImageUrl = cardObject?.details?["thumbnail"].url {
            
            videoPreviewImageView.loadImage(with: videoPreviewImageUrl)
            self.videoUrl = videoUrl
            
        }
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .divorce)
    }
    
    //MARK: - Actions
    @IBAction private func onCloseTap(_ sender: Any) {
        deleteCard()
    }
    @IBAction private func onBottomButtonTap(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationPhotosScreen), object: nil, userInfo: nil)
    }
    @IBAction private func playButtonTap(_ sender: Any) {
        
        guard let videoUrl = videoUrl else { return }
        
        let player = AVPlayer(url: videoUrl)
        
        let playerController = FixedAVPlayerViewController()
        playerController.player = player
        
        let nController = NavigationController(rootViewController: playerController)
        nController.navigationBar.isHidden = true
        
        RouterVC().presentViewController(controller: nController, animated: true) {
            player.play()
        }
        
    }
}
