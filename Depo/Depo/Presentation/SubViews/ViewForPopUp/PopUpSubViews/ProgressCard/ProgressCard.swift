//
//  ProgressCard.swift
//  Depo_LifeTech
//
//  Created by Oleg on 18.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class ProgressCard: BaseCardView, ProgressCardProtocol {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.isHidden = true
        }
    }
    @IBOutlet weak var progress: UIProgressView! {
        willSet {
            newValue.progressTintColor = AppColor.tabBarCardProgressTint.color
            newValue.trackTintColor = AppColor.tabBarCardProgressTrack.color
            newValue.progress = 0
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        willSet {
            newValue.isHidden = true
        }
    }
    @IBOutlet weak var operationLabel: UILabel! {
        willSet {
            newValue.isHidden = true
        }
    }
    @IBOutlet weak var progressLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.text = TextConstants.uploading
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
        }
    }
    @IBOutlet weak var iconImageViewForCurrentFile: LoadingImageView! {
        didSet {
            iconImageViewForCurrentFile.loadingImageViewDelegate = self
            iconImageViewForCurrentFile.isHidden = true
        }
    }
    
    @IBOutlet weak var loadingLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.tabBarCardLabel.color
            newValue.numberOfLines = 1
            newValue.minimumScaleFactor = 0.5
        }
    }
    
    var wrapItem: WrapData?
    var typeOfOperation: OperationType?
    fileprivate let privateQueue = DispatchQueue(label: DispatchQueueLabels.privateConcurentQueue, qos: .userInitiated, attributes: .concurrent)
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.text = ""
        
//        progress.progressTintColor = ColorConstants.blueColor
//        progress.setProgress(0, animated: false)
        
        operationLabel.textColor = ColorConstants.blueColor
        operationLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        operationLabel.text = ""
        
//        progressLabel.textColor = ColorConstants.textGrayColor
//        progressLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
//        progressLabel.text = ""
    }
    
    func setProgress(allItems: Int?, readyItems: Int?) {
        guard let all = allItems else {
            return
        }
        guard let ready = readyItems else {
            return
        }
//        let progressValue = Float(ready) / Float(all)
//        progress.progress = progressValue
        let progressText = String(format: TextConstants.uploading, ready, all)
        loadingLabel.text = progressText
        
        if let typeOfOperation = typeOfOperation, ReachabilityService.shared.isReachable {
            configurateWithType(viewType: typeOfOperation)
        }
    }
    
    func setProgressBar(ratio: Float) {
        progress.progress = ratio
        if let typeOfOperation = typeOfOperation, ReachabilityService.shared.isReachable {
            configurateWithType(viewType: typeOfOperation)
        }
    }
    
    func setImageForUploadingItem(item: WrapData) {
        if wrapItem != item {
            wrapItem = item
            debugLog("Progress Card - start load image")
            iconImageViewForCurrentFile.setLogs(enabled: true)
            iconImageViewForCurrentFile.loadImage(with: item, smooth: true)
        }
    }
    
    func configurateWithType(viewType: OperationType) {
        let isWiFi = ReachabilityService.shared.isReachableViaWiFi
        let networkType = isWiFi ? TextConstants.networkTypeWiFi : TextConstants.mobileData
        let iconImage = isWiFi ? UIImage(named: "WiFiIcon") : UIImage(named: "SyncingPopUpImage")
        typeOfOperation = viewType
        
        switch viewType {
        case .sync:
            operationLabel.text = ""
            titleLabel.text = String(format: TextConstants.popUpSyncing, networkType)
            imageView.image = iconImage
            
        case .upload:
            operationLabel.text = ""
            titleLabel.text = String(format: TextConstants.popUpUploading, networkType)
            imageView.image = iconImage
            
        case .download:
            operationLabel.text = ""
            titleLabel.text = TextConstants.popUpDownload
            imageView.image = iconImage
            
        case .sharedWithMeUpload:
            operationLabel.text = ""
            titleLabel.text = String(format: TextConstants.popUpUploading, networkType)
            imageView.image = iconImage
            
        default:
            operationLabel.text = ""
            titleLabel.text = ""
            imageView.image = nil
        }
            
    }

}

extension ProgressCard: LoadingImageViewDelegate {
    func onImageLoaded(image: UIImage?) {
        privateQueue.async {
//            WidgetService.shared.notifyWidgetAbout(currentImage: image)
        }
    }
    
    func onLoadingImageCanceled() {
        privateQueue.async {
//            WidgetService.shared.notifyWidgetAbout(currentImage: nil)
        }
    }
}
