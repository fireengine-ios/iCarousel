//
//  InstaPickProgressPopup.swift
//  Depo
//
//  Created by Konstantin Studilin on 14/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage


final class InstaPickProgressPopup: ViewController, NibInit {

    @IBOutlet private weak var topCaption: UILabel! {
        didSet {
            topCaption.text = " "
        }
    }
    @IBOutlet private weak var bottomCaption: UILabel! {
        didSet {
            bottomCaption.text = bottomCaptionText
        }
    }
    @IBOutlet private weak var circularLoader: InstaPickCircularLoader! {
        didSet {
            circularLoader.backgroundColor = .clear
            circularLoader.backWidth = 10.0
            circularLoader.backColor = ColorConstants.lightBlueColor
            circularLoader.progressWidth = 10.0
            circularLoader.progressRatio = 0.0
            circularLoader.progressColor = ColorConstants.blueColor
        }
    }

    
    private var topCaptionTexts = [String]()
    private var bottomCaptionText = " "
    private var analyzingImagesUrls = [URL]()
    
    
    private let animationStepDuration = 2.0
    private var animationStepsNumber: Int {
        return max(analyzingImagesUrls.count, topCaptionTexts.count)
    }
    
    static func createPopup(with analyzingImages: [URL], topTexts: [String], bottomText: String) -> InstaPickProgressPopup {
        let controller = InstaPickProgressPopup.initFromNib()
        controller.analyzingImagesUrls = analyzingImages
        controller.topCaptionTexts = topTexts
        controller.bottomCaptionText = bottomText
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        return controller
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupInitialStates()
        startInfiniteAnimation()
    }
 

    
    private func setupInitialStates() {
        circularLoader.layoutIfNeeded()
        circularLoader.set(imageUrl: analyzingImagesUrls.first, animated: false)
        topCaption.text = topCaptionTexts.first
    }
    
    private func startInfiniteAnimation() {
        circularLoader.animateInfinitely(numberOfSteps: animationStepsNumber, timeForStep: animationStepDuration) { [weak self] step, _ in
            guard let `self` = self else { return }
            
            self.changeImage(on: step)
            self.changeTopCaption(on: step)
        }
    }
    
    private func changeImage(on step: Int) {
        guard analyzingImagesUrls.count > 1 else { return }
        
        let imageIndex = step % analyzingImagesUrls.count
        let imageUrl = analyzingImagesUrls[safe: imageIndex]
        
        circularLoader.set(imageUrl: imageUrl, animated: true)
    }
    
    
    private func changeTopCaption(on step: Int) {
        guard !topCaptionTexts.isEmpty else { return }
        
        let topTextIndex = step % topCaptionTexts.count
        UIView.transition(with: topCaption,
                          duration: NumericConstants.instaPickImageViewTransitionDuration,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.topCaption.text = self.topCaptionTexts[safe: topTextIndex]
        }, completion: nil)
    }
    
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
