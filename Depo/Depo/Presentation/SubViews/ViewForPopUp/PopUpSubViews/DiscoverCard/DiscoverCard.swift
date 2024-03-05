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
    private lazy var homeCardsServiseDiscoverCard: HomeCardsService = factory.resolve()
    
    var imageUrls: [String] = []
    var groupId: [Int] = []
    
    @objc func updateImageUrls() {
        let imageUrls = userDefaultsVars.imageUrlsForBestScene
        if let newImageUrls = imageUrls as? [String] {
            self.imageUrls = newImageUrls.count > 5 ? Array(newImageUrls.prefix(5)) : newImageUrls
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func updateGroupId() {
        let groupId = userDefaultsVars.groupIdBestScene
        if let newGroupId = groupId as? [Int] {
            self.groupId = newGroupId
            collectionView.reloadData()
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
            updateGroupId()
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
        let router = RouterVC()
        let controller = router.bestSceneAllGroupController()
        router.pushViewController(viewController: controller)
    }
    
}

extension DiscoverCard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! DiscoverCollectionViewCell
        if let url = URL(string: imageUrls[indexPath.row]) {
            cell.imageView.sd_setImage(with: url) { image, _, _, _ in
                if let image = image {
                    cell.imageView.image = image
                    cell.bottomShadowView.image = image
                    cell.topShadowView.image = image
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedGroupId = self.groupId[indexPath.row]
        
        homeCardsServiseDiscoverCard.getBestGroupWithId(with: selectedGroupId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                
                let coverPhotoUrl = response.coverPhoto.tempDownloadURL
                let fileListUrls = response.fileList.compactMap { $0.tempDownloadURL }
                
                DispatchQueue.main.async {
                    let router = RouterVC()
                    let controller = router.bestSceneAllGroupSortedViewController(coverPhotoUrl: coverPhotoUrl ?? "", fileListUrls: fileListUrls)
                    router.pushViewController(viewController: controller)
                }
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
