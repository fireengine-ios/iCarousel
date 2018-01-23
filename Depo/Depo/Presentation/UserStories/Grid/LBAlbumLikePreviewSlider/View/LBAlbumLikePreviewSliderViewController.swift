//
//  LBAlbumLikePreviewSliderViewController.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class LBAlbumLikePreviewSliderViewController: UIViewController {
    var output: LBAlbumLikePreviewSliderViewOutput!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func initFromXIB() -> LBAlbumLikePreviewSliderViewController {
        return LBAlbumLikePreviewSliderViewController(nibName: "LBAlbumLikePreviewSliderViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady(collectionView: collectionView)
    }
    
    @objc func labelTouchRecognition(_ sender: Any) {
        output.sliderTitlePressed()
    }
    
    func reloadAllData() {
        output.reloadData()
    }
}

extension LBAlbumLikePreviewSliderViewController: LBAlbumLikePreviewSliderViewInput {
    func setupInitialState() {
        view.backgroundColor = UIColor.lrSkinTone
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = UIColor.gray
        titleLabel.alpha = 0.5
        titleLabel.text = TextConstants.albumLikeSlidertitle
        titleLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTouchRecognition))
        titleLabel.addGestureRecognizer(tapGesture)
    }
}
