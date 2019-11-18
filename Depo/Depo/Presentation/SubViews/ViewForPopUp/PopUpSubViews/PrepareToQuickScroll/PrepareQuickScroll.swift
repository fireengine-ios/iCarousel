
//
//  PrepareQuickScroll.swift
//  Depo
//
//  Created by Konstantin on 9/20/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PrepareQuickScroll: BaseCardView {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            titleLabel.textColor = ColorConstants.textGrayColor
            titleLabel.text = TextConstants.prepareQuickScroll
        }
    }
    
    @IBOutlet private weak var titleImageView: UIImageView! {
        didSet {
            ///an icon will be here later
            titleImageView.image = nil
        }
    }
    
    @IBOutlet private weak var progressView: UIProgressView! {
        didSet {
            progressView.progressTintColor = ColorConstants.blueColor
            progressView.progress = 0
        }
    }
    
    private var timer: Timer?
    
    private let progressStep: Float = 0.02
    
    
    override func configurateView() {
        super.configurateView()
        
        canSwipe = false
        animateProgress()
        let timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(animateProgress),
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
    
    @objc private func animateProgress() {
        let currentProgress = progressView.progress
        let newProgress = currentProgress < 1 ? currentProgress + progressStep : 0
        progressView.progress = newProgress
    }
    
}
