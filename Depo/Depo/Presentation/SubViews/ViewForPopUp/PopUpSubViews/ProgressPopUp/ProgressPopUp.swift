//
//  ProgressPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 18.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class ProgressPopUp: BaseView, ProgressPopUpProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var iconImageViewForCurrentFile: LoadingImageView!
    
    var wrapItem: WrapData?
    var typeOfOperation: OperationType?
    
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
    
    func setProgress(allItems: Int?, readyItems: Int?){
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
        
        if let typeOfOperation = typeOfOperation{
            configurateWithType(viewType: typeOfOperation)
        }
    }
    
    func setProgressBar(ratio: Float) {
        progress.progress = ratio
        if let typeOfOperation = typeOfOperation{
            configurateWithType(viewType: typeOfOperation)
        }
    }
    
    func setImageForUploadingItem(item: WrapData){
        if wrapItem != item{
            wrapItem = item
            iconImageViewForCurrentFile.loadImageForItem(object: item, smooth: true)
        }
    }
    
    func configurateWithType(viewType: OperationType){
        let isWiFi = ReachabilityService().isReachableViaWiFi
        let networkType = isWiFi ? TextConstants.networkTypeWiFi : TextConstants.mobileData
        typeOfOperation = viewType
        
        switch viewType {
        case .sync:
            operationLabel.text = ""
            titleLabel.text = TextConstants.popUpSyncing + " " + networkType
            imageView.image = UIImage(named: "SyncingPopUpImage")
            
        case .upload:
            operationLabel.text = ""
            titleLabel.text = TextConstants.popUpUploading + " " + networkType
            imageView.image = UIImage(named: "SyncingPopUpImage")
            
        case .download:
            operationLabel.text = ""
            titleLabel.text = TextConstants.popUpDownload
            imageView.image = UIImage(named: "SyncingPopUpImage")
            
        default:
            operationLabel.text = ""
            titleLabel.text = ""
            imageView.image = nil
        }
            
    }

}
