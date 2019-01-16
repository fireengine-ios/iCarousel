//
//  InstaPickProgressPopup.swift
//  Depo
//
//  Created by Konstantin Studilin on 14/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage


final class InstaPickProgressPopup: ViewController {

    @IBOutlet private weak var topCaption: UILabel! {
        didSet {
            topCaption.text = ""
        }
    }
    @IBOutlet private weak var bottomCaption: UILabel! {
        didSet {
            bottomCaption.text = bottomCaptionText
        }
    }
    @IBOutlet private weak var circularLoader: LTCircularProgressView! {
        didSet {
            circularLoader.backWidth = 10.0
            circularLoader.backColor = ColorConstants.lightBlueColor
            circularLoader.progressWidth = 10.0
            circularLoader.progressRatio = 0.0
            circularLoader.progressColor = ColorConstants.blueColor
        }
    }
    @IBOutlet private weak var analyzingImage: UIImageView! {
        didSet {
            analyzingImage.contentMode = .scaleAspectFill
        }
    }
    
    private var topCaptionTexts = [String]()
    private var bottomCaptionText = ""
    private var analyzingImagesUrls = [URL]()
    
    
    private let animationStepDuration = 2.0
    private var animationStepsNumber: Int {
        return max(analyzingImagesUrls.count, topCaptionTexts.count)
    }
    private let transitionDuration = 0.25
    
    
    static func createPopup(with analyzingImages: [URL], topTexts: [String], bottomText: String) -> InstaPickProgressPopup {
        let controller = InstaPickProgressPopup(nibName: "InstaPickProgressPopup", bundle: nil)
        controller.analyzingImagesUrls = analyzingImages
        controller.topCaptionTexts = topTexts
        controller.bottomCaptionText = bottomText
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        return controller
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startInfiniteAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupAnalyzingImage()
    }
    

    private func setupAnalyzingImage() {
        let inset: CGFloat = 8.0
        let diameter = (circularLoader.innerRadius - inset) * 2.0
        let startPoint = (analyzingImage.layer.bounds.width - diameter) * 0.5
        
        let maskLayerRect = CGRect(x: startPoint, y: startPoint, width: diameter, height: diameter)
        let ovalPath = UIBezierPath(ovalIn: maskLayerRect)
        let maskLayer = CAShapeLayer()
        maskLayer.path = ovalPath.cgPath
        
        analyzingImage.layer.mask = maskLayer
    }
    
    private func startInfiniteAnimation() {
        circularLoader.animateInfinitely(numberOfSteps: animationStepsNumber, timeForStep: animationStepDuration) { [weak self] step, _ in
            guard let `self` = self else { return }
            
            self.changeImage(on: step)
            self.changeTopCaption(on: step)
        }
    }
    
    private func changeImage(on step: Int) {
        guard !analyzingImagesUrls.isEmpty else { return }
        
        let imageIndex = step % analyzingImagesUrls.count
        analyzingImage.sd_setImage(with: analyzingImagesUrls[safe: imageIndex], placeholderImage: nil, options: [.avoidAutoSetImage], completed: { [weak self] image, error, cahceType, _ in
            guard let `self` = self else {
                return
            }
            
            UIView.transition(with: self.analyzingImage,
                              duration: self.transitionDuration,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.analyzingImage.image = image
            }, completion: nil)
        })
    }
    
    
    private func changeTopCaption(on step: Int) {
        guard !topCaptionTexts.isEmpty else { return }
        
        let topTextIndex = step % topCaptionTexts.count
        UIView.transition(with: topCaption,
                          duration: transitionDuration,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.topCaption.text = self.topCaptionTexts[safe: topTextIndex]
        }, completion: nil)
    }
    
    
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
