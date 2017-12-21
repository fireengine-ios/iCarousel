//
//  PrepareToAutoSync.swift
//  Depo_LifeTech
//
//  Created by Oleg on 12.12.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PrepareToAutoSync: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var timer: Timer?
    
    override class func initFromNib() -> PrepareToAutoSync{
        if let view = super.initFromNib() as? PrepareToAutoSync{
            return view
        }
        return PrepareToAutoSync()
    }
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.text = TextConstants.prepareToAutoSunc
        
        progressView.progressTintColor = ColorConstants.blueColor
        progressView.setProgress(0, animated: false)
        
        let isWiFi = ReachabilityService().isReachableViaWiFi
        if (isWiFi){
            titleImageView.image = UIImage(named: "SyncingViaWiFiPopUpImage")
        }else{
            titleImageView.image = UIImage(named: "SyncingPopUpImage")
        }
        
        let timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(setProgress),
                                         userInfo: nil,
                                         repeats: true)
        timer.fire()
        
    }
    
    deinit {
        if let t = timer {
            t.invalidate()
            timer = nil
        }
    }
    
    @objc func setProgress(){
        if progressView.progress == 1{
            progressView.progress = 0
        }else{
            progressView.progress = progressView .progress + 0.02
        }
    }

}
