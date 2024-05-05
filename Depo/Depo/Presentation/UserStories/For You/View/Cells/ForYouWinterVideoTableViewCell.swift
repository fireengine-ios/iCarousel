//
//  ForYouWinterVideoTableViewCell.swift
//  Depo
//
//  Created by Rustam on 04.05.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol ForYouWinterVideoTableViewCellDelegate: AnyObject {
    func saveTimelineCard(id: Int)
    func setTimelineNil()
    func shareTimeline(item: BaseDataSourceItem, type: CardShareType)
}

class ForYouWinterVideoTableViewCell: UITableViewCell {
    
    weak var delegate: ForYouWinterVideoTableViewCellDelegate?
    
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
            newValue.textColor = AppColor.tealBlue.color
            newValue.font = .appFont(.medium, size: 12)
        }
    }
    
    @IBOutlet weak var closeButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
            newValue.tintColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        willSet {
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
            newValue.image = Image.iconPlayPoint.image
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    private var videoUrl: URL?
    private var winterVideoResponse: WinterThemeVideoResponse?
    private var type: CardActionType = .save
    
    func dateConverter(epochTimeInMilliseconds: UInt64) -> String {
        let epochTimeInSeconds = TimeInterval(epochTimeInMilliseconds) / 1000
        let date = Date(timeIntervalSince1970: epochTimeInSeconds)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func configure(with item: WinterThemeVideoResponse?) {
//        saveButton.setTitle(item?.saved ?? false ? TextConstants.tabBarShareLabel : TextConstants.save, for: .normal)
        self.winterVideoResponse = item
        
        let year = dateConverter(epochTimeInMilliseconds: UInt64(item?.details?.createdDate ?? 0))
        titleLabel.text = item?.title
        descriptionLabel.text = item?.description
        
//        type = item?.saved ?? false ? .display : .save
//        switch type {
//        case .display:
//            saveButton.setTitle(TextConstants.homeLikeFilterViewPhoto, for: .normal)
//            shareButton.setTitle(TextConstants.tabBarShareLabel, for: .normal)
//            shareButton.isHidden = true //change to false if needed
//        case .save:
            saveButton.setTitle(TextConstants.save, for: .normal)
//            shareButton.isHidden = true
//        }
        
        guard let url = URL(string: item?.details?.metadata?.thumbnailMedium ?? "") else {
            return
        }
        thumbnailImageView.loadImageData(with: url, animated: false)
        
        guard let videoUrl = URL(string: item?.details?.tempDownloadURL ?? "") else {
            return
        }
        self.videoUrl = videoUrl
    }
    
    @objc private func imageTapped() {
        showTimelineVideo()
    }
    
    @IBAction func closeButtonTap(_ sender: Any) {
        delegate?.setTimelineNil()
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
//        switch type {
//        case .display:
//            showTimelineVideo()
//        case .save:
            delegate?.saveTimelineCard(id: winterVideoResponse?.id ?? 0)
//        }
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        let item = WrapData(timelineResponse: winterVideoResponse!)
        delegate?.shareTimeline(item: item, type: .videoOrigin)
    }
    
    private func showTimelineVideo() {
        guard let videoUrl = videoUrl else {
            assertionFailure()
            return
        }
        let player = AVPlayer(url: videoUrl)
        
        let playerController = WinterVideoNewAvPlayerViewController(item: winterVideoResponse)
        playerController.player = player
        
        let nController = NavigationController(rootViewController: playerController)
        nController.navigationBar.isHidden = false
        
        RouterVC().presentViewController(controller: nController, animated: true) {
            player.play()
        }
    }
}
