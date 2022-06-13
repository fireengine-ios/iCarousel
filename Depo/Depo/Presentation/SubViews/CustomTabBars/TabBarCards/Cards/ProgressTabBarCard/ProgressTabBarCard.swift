//
//  ProgressTabBarCard.swift
//  Lifebox
//
//  Created by Hady on 6/5/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class ProgressTabBarCard: BaseTabBarCard {

    @IBOutlet private weak var iconImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }

    @IBOutlet private weak var expandMinimizeButton: UIButton! {
        willSet {
            newValue.setTitle(nil, for: .normal)
            newValue.setImage(
                Image.iconArrowDown.image(withTintColor: .tabBarCardLabel, in: newValue),
                for: .normal
            )
        }
    }

    @IBOutlet private weak var statusLabelMinimized: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
        }
    }

    @IBOutlet private weak var statusLabelExpanded: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
        }
    }

    @IBOutlet private weak var progressLabelMinimized: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
        }
    }

    @IBOutlet private weak var progressLabelExpanded: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
        }
    }

    @IBOutlet weak var expandedLabelsContainerView: UIStackView!

    @IBOutlet private weak var progressView: UIProgressView! {
        willSet {
            newValue.progressTintColor = AppColor.tabBarCardProgressTint.color
            newValue.trackTintColor = AppColor.tabBarCardProgressTrack.color
            newValue.progress = 0
        }
    }

    @IBOutlet private weak var currentItemImageView: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }

    private(set) var isExpanded = false
    private var currentOperationType: OperationType?
    private lazy var reachabilityService = ReachabilityService.shared

    override func awakeFromNib() {
        super.awakeFromNib()
        expandMinimizeButton.isHidden = true
        setExpanded(isExpanded, animated: false)
    }

    func setExpanded(_ isExpanded: Bool, animated: Bool = true) {
        self.isExpanded = isExpanded

        iconImageView.isHidden = !isExpanded
        expandedLabelsContainerView.isHidden = !isExpanded
        currentItemImageView.isHidden = !isExpanded
        statusLabelMinimized.isHidden = isExpanded
        progressLabelMinimized.isHidden = isExpanded
        expandMinimizeButton.transform = isExpanded ? .identity : .init(rotationAngle: .pi)

        guard animated else { return }
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration) {
            self.layoutIfNeeded()
        }
    }

    func setProgress(allItems: Int?, readyItems: Int?) {
        guard let all = allItems, let ready = readyItems else {
            return
        }

        let progressText = String(format: TextConstants.popUpProgress, ready, all)
        progressLabelExpanded.text = progressText
        progressLabelMinimized.text = progressText
    }

    func setProgress(ratio: Float) {
        progressView.progress = ratio

        if let operationType = currentOperationType, reachabilityService.isReachable {
            configure(with: operationType)
        }
    }

    func setImageForUploadingItem(item: WrapData) {
        debugLog("Progress Card - start load image")
        currentItemImageView.setLogs(enabled: true)
        currentItemImageView.loadImage(with: item, smooth: true)
        currentItemImageView.isHidden = !isExpanded
        expandMinimizeButton.isHidden = false
    }

    func configure(with operationType: OperationType) {
        self.currentOperationType = operationType

        let isWiFi = reachabilityService.isReachableViaWiFi
        let networkType = isWiFi ? TextConstants.networkTypeWiFi : TextConstants.mobileData
        let iconImage = isWiFi ? Image.iconWifi : Image.iconNetworkLTE

        currentItemImageView.isHidden = true
        iconImageView.image = iconImage.image(
            withTintColor: .tabBarCardLabel,
            in: iconImageView
        )

        switch operationType {
        case .sync:
            statusLabelExpanded.text = String(format: TextConstants.popUpSyncing, networkType)
            statusLabelMinimized.text = localized(.syncing)

        case .upload:
            statusLabelExpanded.text = String(format: TextConstants.popUpUploading, networkType)
            statusLabelMinimized.text = TextConstants.uploading

        case .download:
            statusLabelExpanded.text = TextConstants.popUpDownload
            statusLabelMinimized.text = localized(.downloading)

        case .sharedWithMeUpload:
            statusLabelExpanded.text = String(format: TextConstants.popUpUploading, networkType)
            statusLabelMinimized.text = TextConstants.uploading

        default:
            statusLabelExpanded.text = nil
            statusLabelMinimized.text = nil
            iconImageView.image = nil
        }
    }

    @IBAction private func expandMinimizeButtonTapped() {
        setExpanded(!isExpanded)
    }
}
