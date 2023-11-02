//
//  ForYouTimelineTableViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 11.10.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouTimelineTableViewCellDelegate: AnyObject {
    func saveTimelineCard(id: Int)
    func setTimelineNil()
    func shareTimeline(item: BaseDataSourceItem, type: CardShareType)
}

class ForYouTimelineTableViewCell: UITableViewCell {
    
    weak var delegate: ForYouTimelineTableViewCellDelegate?
    
    @IBOutlet weak var bgView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
            newValue.backgroundColor = AppColor.secondaryBackground.color
        }
    }
    
    @IBOutlet weak var titleImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconConfetti.image
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.text = String(format: localized(.timelineHeader), Int(Date().getYear()))
            newValue.textColor = AppColor.tealBlue.color
            newValue.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet weak var closeImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelBorder.image
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(closeImageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = String(format: localized(.timelineDescription), Int(Date().getYear()))
            newValue.textColor = AppColor.darkBlue.color
            newValue.font = .appFont(.regular, size: 12)
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var thumbnailImageView: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 15
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    @IBOutlet weak var saveButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.setTitle(TextConstants.save, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        willSet {
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.setTitle(TextConstants.tabBarShareLabel, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 12)
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var playImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconPlay.image
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    private var videoUrl: URL?
    private var timelineResponse: TimelineResponse?
    private var type: CardActionType = .display
    
    func configure(with item: TimelineResponse?) {
        saveButton.setTitle(item?.saved ?? false ? TextConstants.tabBarShareLabel : TextConstants.save, for: .normal)
        self.timelineResponse = item
        
        type = item?.saved ?? false ? .display : .save
        switch type {
        case .display:
            saveButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
            shareButton.setTitle(TextConstants.tabBarShareLabel, for: .normal)
            shareButton.isHidden = false
        case .save:
            saveButton.setTitle(TextConstants.save, for: .normal)
            shareButton.isHidden = true
        }
        
        guard let url = URL(string: item?.details.metadata.thumbnailMedium ?? "") else {
            return
        }
        thumbnailImageView.loadImageData(with: url, animated: false)
        
        guard let videoUrl = URL(string: item?.details.tempDownloadURL ?? "") else {
            return
        }
        self.videoUrl = videoUrl
    }
    
    @objc private func imageTapped() {
        showTimelineVideo()
    }
    
    @objc private func closeImageTapped() {
        delegate?.setTimelineNil()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        switch type {
        case .display:
            showTimelineVideo()
        case .save:
            delegate?.saveTimelineCard(id: timelineResponse?.id ?? 0)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let item = WrapData(timelineResponse: timelineResponse!)
        delegate?.shareTimeline(item: item, type: .origin)
    }
    
    private func showTimelineVideo() {
        guard let videoUrl = videoUrl else {
            assertionFailure()
            return
        }
        let player = AVPlayer(url: videoUrl)
        
        let playerController = NewAvPlayerViewController(item: timelineResponse)
        playerController.player = player
        
        let nController = NavigationController(rootViewController: playerController)
        nController.navigationBar.isHidden = false
        
        RouterVC().presentViewController(controller: nController, animated: true) {
            player.play()
        }
    }
}
