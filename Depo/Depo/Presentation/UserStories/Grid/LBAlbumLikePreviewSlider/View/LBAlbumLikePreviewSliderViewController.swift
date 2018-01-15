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
        collectionView.register(nibCell: AlbumCell.self)
        output.viewIsReady()
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
    func setupCollectionView() {
        collectionView.reloadData()
    }
}

extension LBAlbumLikePreviewSliderViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: AlbumCell.self, for: indexPath)        
        
        if let type = MyStreamType(rawValue: indexPath.item) {
            let items = output.previewItems(withType: type)
            cell.setup(forItems: items, titleText: type.title)
        }
        
        return cell
    }
}

extension LBAlbumLikePreviewSliderViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let type = MyStreamType(rawValue: indexPath.item) {
            output.onSelectItem(type: type)
        }
    }
}

extension LBAlbumLikePreviewSliderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 110)
    }
}
