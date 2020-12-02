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
    
    @IBOutlet weak var collectionView: UICollectionView! {
        willSet {
            newValue.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    
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
    }
    
}
