//
//  BestSceneAllGroupViewController.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit

class BestSceneAllGroupViewController: BaseViewController {
    
    private let userDefaultsVars = UserDefaultsVars()
    private lazy var homeCardsServisBestSceneAllGroup: HomeCardsService = factory.resolve()

    var imageUrls: [String] = []
    var timestamp: Int = 0
    var groupId: [Int] = []
    
    private lazy var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        view.layer.cornerRadius = 16
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.bestscenediscovercardtitle))
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateImageUrls()
    }
    
    @objc func updateImageUrls() {
        let imageUrls = userDefaultsVars.imageUrlsForBestScene
        if let newImageUrls = imageUrls as? [String] {
            self.imageUrls = newImageUrls
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        let createdDate = userDefaultsVars.dateForBestScene
        if let newDate = createdDate as? Int {
            self.timestamp = newDate
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        let groupId = userDefaultsVars.groupIdBestScene
        if let newGroupId = groupId as? [Int] {
            self.groupId = newGroupId
            collectionView.reloadData()
        }
    }
    
    func dateFormat() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self.timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }

    private func setupLayout() {
        
        view.addSubview(customView)
        customView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: customView.trailingAnchor)
        ])
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 30
        layout.sectionInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(BestSceneAllGroupCollectionViewCell.self, forCellWithReuseIdentifier: "BestSceneAllGroupCollectionViewCell")
        return collectionView
    }()
}

extension BestSceneAllGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestSceneAllGroupCollectionViewCell", for: indexPath) as! BestSceneAllGroupCollectionViewCell
        
        if let url = URL(string: imageUrls[indexPath.row]) {
            cell.imageView.sd_setImage(with: url) { image, _, _, _ in
                if let image = image {
                    cell.imageView.image = image
                    cell.bottomShadowView.image = image
                    cell.topShadowView.image = image
                }
            }
        }
        
        cell.dateLabel.text = dateFormat()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedGroupId = self.groupId[indexPath.row]
        
        homeCardsServisBestSceneAllGroup.getBestGroupWithId(with: selectedGroupId) { [weak self] result in
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
