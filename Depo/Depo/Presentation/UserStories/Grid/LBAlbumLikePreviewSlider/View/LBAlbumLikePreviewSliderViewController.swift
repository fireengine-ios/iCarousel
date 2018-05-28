//
//  LBAlbumLikePreviewSliderViewController.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class LBAlbumLikePreviewSliderViewController: ViewController {
    var output: LBAlbumLikePreviewSliderViewOutput!
    
    var sliderTitle: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    class func initFromXIB() -> LBAlbumLikePreviewSliderViewController {
        return LBAlbumLikePreviewSliderViewController(nibName: "LBAlbumLikePreviewSliderViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady(collectionView: collectionView)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData),
                                               name: .changeFaceImageStatus,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func labelTouchRecognition(_ sender: Any) {
        output.sliderTitlePressed()
    }
    
    func reloadAllData() {
        output.reloadData()
    }
    
    @objc func reloadData() {
        output.reloadData()
    }
}

// MARK: - LBAlbumLikePreviewSliderViewInput

extension LBAlbumLikePreviewSliderViewController: LBAlbumLikePreviewSliderViewInput {
    
    func setupInitialState() {
        view.backgroundColor = UIColor.lrSkinTone
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = UIColor.gray
        titleLabel.alpha = 0.5
        titleLabel.text = sliderTitle ?? TextConstants.albumLikeSlidertitle
        titleLabel.isUserInteractionEnabled = true

        ///LR-4845 we dont need clickable title for now
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTouchRecognition))
//        titleLabel.addGestureRecognizer(tapGesture)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
}
