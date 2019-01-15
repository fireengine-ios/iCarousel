//
//  InstaPickProgressPopup.swift
//  Depo
//
//  Created by Konstantin Studilin on 14/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class InstaPickProgressPopup: ViewController {
    
    @IBOutlet weak var topCaption: UILabel!
    @IBOutlet weak var bottomCaption: UILabel!
    @IBOutlet weak var circularLoader: LTCircularProgressView! //{
//        didSet {
//            circularLoader.backWidth = 10.0
//            circularLoader.backColor = .gray
//            circularLoader.progressWidth = 10.0
//            circularLoader.progressRatio = 0.0
//            circularLoader.progressColor = .red
//        }
//    }
    @IBOutlet weak var analyzingImage: UIImageView!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        circularLoader.animateConstantly()
    }
    
    private func setupAnalyzingImage() {
        let inset = circularLoader.radius - circularLoader.innerRadius - circularLoader.backWidth
        
        let ovalPath = UIBezierPath(ovalIn: analyzingImage.layer.bounds)
        let maskLayer = CAShapeLayer()
        maskLayer.path = ovalPath.cgPath
        
    }
}
