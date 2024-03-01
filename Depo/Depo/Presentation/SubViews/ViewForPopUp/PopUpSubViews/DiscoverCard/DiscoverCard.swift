//
// DiscoverCard.swift
// Lifebox
//
// Created by Rustam Manafov on 13.02.24.
// Copyright © 2024 LifeTech. All rights reserved.
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
    private let userDefaultsVars = UserDefaultsVars()
    
    var imageUrls: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @objc func updateImageUrls() {
        let imageUrls = userDefaultsVars.imageUrlsForBestScene
        if let newImageUrls = imageUrls as? [String] {
            self.imageUrls = newImageUrls.count > 5 ? Array(newImageUrls.prefix(5)) : newImageUrls
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func setupCollectionView() {
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
    
    override func configurateView() {
        super.configurateView()
        titleLabel.text = localized(.bestscenediscovercardtitle)
        descriptionLabel.text = localized(.bestscenediscovercardbody)
        showAllPictureLabel.setTitle(localized(.forYouSeeAll), for: .normal)
        setupCollectionView()
    }
    
    func configurateWithType(viewType: OperationType) {
        if viewType == .discoverCard {
            updateImageUrls()
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
            cell.imageView.sd_setImage(with: url, placeholderImage: nil)
            cell.bottomShadowView.sd_setImage(with: url, placeholderImage: nil)
            cell.topShadowView.sd_setImage(with: url, placeholderImage: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(":smiley:")
    }
    
}
