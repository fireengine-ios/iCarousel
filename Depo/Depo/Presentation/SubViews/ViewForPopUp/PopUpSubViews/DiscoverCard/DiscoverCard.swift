//
//  DiscoverCard.swift
//  Lifebox
//
//  Created by Rustam Manafov on 13.02.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCollectionView()
    }
    
    override func configurateView() {
        super.configurateView()
        
    }
    
    func configurateWithType(viewType: OperationType) {
        
        if viewType == .discoverCard {
            
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
    
    private func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DiscoverCollectionViewCell.self, forCellWithReuseIdentifier: "DiscoverCollectionViewCell")
        collectionView.showsHorizontalScrollIndicator = false

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 145, height: 145)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }

}


extension DiscoverCard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! DiscoverCollectionViewCell
        
        cell.imageView.image = UIImage(named: "iphone")
        cell.bottomShadowView.image = UIImage(named: "iphone")
        cell.topShadowView.image = UIImage(named: "iphone")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("😃")
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//    }
    
}
