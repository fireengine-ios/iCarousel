//
//  ProgressPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 18.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class ProgressPopUp: BaseView, ProgressPopUpProtocol {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    override class func initFromNib() -> ProgressPopUp{
        if let view = super.initFromNib() as? ProgressPopUp{
            return view
        }
        return ProgressPopUp()
    }
    
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
        let progressValue = Float(ready) / Float(all)
        progress.progress = progressValue
        let progressText = String(format: TextConstants.popUpProgress, ready, all)
        progressLabel.text = progressText
    }
    
    func configurateWithType(viewType: OperationType){
        switch viewType {
        case .sync:
            operationLabel.text = ""
            titleLabel.text = TextConstants.popUpSyncing
            imageView.image = UIImage(named: "SyncingPopUpImage")
            
        case .upload:
            operationLabel.text = ""
            titleLabel.text = TextConstants.popUpUploading
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
