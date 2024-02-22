//
//  DiscoverCard.swift
//  Lifebox
//
//  Created by Rustam Manafov on 13.02.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

protocol DiscoverCardPopupDelegate: AnyObject {
    func removeDiscoverCard()
}

class DiscoverCard: BaseCardView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var showAllPictureLabel: UIButton!
    
    private var operation: OperationType?
    weak var popupDelegate: DiscoverCardPopupDelegate?
    
    var imageUrls: [String] = []
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCollectionView() {
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(DiscoverCollectionViewCell.self, forCellWithReuseIdentifier: "DiscoverCollectionViewCell")
        collectionView?.showsHorizontalScrollIndicator = false
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 145, height: 145)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        collectionView?.collectionViewLayout = layout
    }
    
    override func configurateView() {
        super.configurateView()
        
        setupCollectionView()
    }
    
    func configurateWithType(viewType: OperationType) {
        if viewType == .discoverCard {
            setupCollectionView()
        }
    }
    
    func updateDiscoverCard(with imageUrls: [String]) {
        self.imageUrls = imageUrls.count > 5 ? Array(imageUrls.prefix(5)) : imageUrls
        print(" ⚠️ Updated image URLs: \(self.imageUrls)")
        
        if let collectionView = collectionView {
            collectionView.reloadData()
        } else {
            print("⚠️", "collection view is nil")
        }
        
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.manuallyDeleteCardsByType(type: operation ?? .discoverCard)
    }
    
    @IBAction func deleteCardAction(_ sender: Any) {
        popupDelegate?.removeDiscoverCard()
        deleteCard()
    }
    
    @IBAction func showAllPicture(_ sender: Any) {
        
    }
}

extension DiscoverCard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! DiscoverCollectionViewCell
        
        if let url = URL(string: imageUrls[indexPath.row]) {
            cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "iphone"))
            cell.bottomShadowView.sd_setImage(with: url, placeholderImage: UIImage(named: "iphone"))
            cell.topShadowView.sd_setImage(with: url, placeholderImage: UIImage(named: "iphone"))
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("😃")
    }
}
