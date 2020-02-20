//
//  ProgressCard.swift
//  Depo_LifeTech
//
//  Created by Oleg on 18.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class ProgressCard: BaseCardView, ProgressCardProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var iconImageViewForCurrentFile: LoadingImageView! {
        didSet { iconImageViewForCurrentFile.loadingImageViewDelegate = self }
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
        
        progress.progressTintColor = ColorConstants.blueColor
        progress.setProgress(0, animated: false)
        
        operationLabel.textColor = ColorConstants.blueColor
        operationLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        operationLabel.text = ""
        
        progressLabel.textColor = ColorConstants.textGrayColor
        progressLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        progressLabel.text = ""
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
        let progressText = String(format: TextConstants.popUpProgress, ready, all)
        progressLabel.text = progressText
        
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
            WidgetService.shared.notifyWidgetAbout(currentImage: image)
        }
    }
    
    func onLoadingImageCanceled() {
        privateQueue.async {
            WidgetService.shared.notifyWidgetAbout(currentImage: nil)
        }
    }
}
