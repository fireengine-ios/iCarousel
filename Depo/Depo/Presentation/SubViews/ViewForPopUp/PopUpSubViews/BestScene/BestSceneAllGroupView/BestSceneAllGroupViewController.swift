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
    weak var output: HomePageInteractorOutput!
    
    private var isScreenPresented = false
        
    private let userDefaults = UserDefaultsVars()
    private var bestSceneCards: [HomeCardResponse] = []

    var imageUrls: [String] = []
    var timestamp: Int = 0
    var groupId: [Int] = []
    var selectedId: [Int] = []
    
    private lazy var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var closeSelfButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(closeSelf))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.bestscenediscovercardtitle))
        
        setupLayout()
        
        navigationItem.leftBarButtonItem = closeSelfButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getBestScene {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.updateImageUrls()
            }
        }
    }
    
    private func getBestScene(completion: @escaping () -> Void) {
        homeCardsServisBestSceneAllGroup.getBestGroup { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                _ = response.map { burstGroup -> HomeCardResponse in
                    let homeCard = HomeCardResponse()
                    homeCard.id = burstGroup.id
                    homeCard.type = .discoverCard
                    let imageUrls = response.map { $0.coverPhoto?.metadata?.thumbnailMedium }.compactMap { $0 }
                    let burstGroupId = response.map { $0.id }.compactMap { $0 }
                    let createdDate = response.first?.groupDate
                    
//                    self.output?.didObtainHomeCardsBestScene(homeCard, imageUrls: imageUrls, createdDate: createdDate ?? 0, groupId: burstGroupId)
                    
                    self.bestSceneCards = [homeCard]
                    self.userDefaultsVars.imageUrlsForBestScene = imageUrls
                    self.userDefaultsVars.dateForBestScene = createdDate ?? 0
                    self.userDefaultsVars.groupIdBestScene = burstGroupId
                    
                    return homeCard
                }
            case .failed(let error):
                DispatchQueue.main.async {
                    self.output?.didObtainError(with: error.localizedDescription, isNeedStopRefresh: false)
                }
            }
            completion()
        }
    }
    
    @objc private func closeSelf() {
        let router = RouterVC()
        router.openTabBarItem(index: .discover)
    }
    
    @objc func updateImageUrls() {
        
        let imageUrls = userDefaultsVars.imageUrlsForBestScene
        self.imageUrls = imageUrls
        
        
        let createdDate = userDefaultsVars.dateForBestScene
        self.timestamp = createdDate
        
        let groupId = userDefaultsVars.groupIdBestScene
        self.groupId = groupId
        
        self.collectionView.reloadData()
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
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        
        guard !isScreenPresented else { return }
        isScreenPresented = true

        let selectedGroupId = self.groupId[indexPath.row]
        
        homeCardsServisBestSceneAllGroup.getBestGroupWithId(with: selectedGroupId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                
                let coverPhotoUrl = response.coverPhoto.tempDownloadURL
                let fileListUrls = response.fileList.compactMap { $0.tempDownloadURL }
                
                let selectedGroupID = response.id
                                                
                self.selectedId.append(response.coverPhoto.id)
                
                for ids in response.fileList {
                    self.selectedId.append(ids.id)
                }
                
                DispatchQueue.main.async {
                    let router = RouterVC()
                    let controller = router.bestSceneAllGroupSortedViewController(coverPhotoUrl: coverPhotoUrl ?? "", fileListUrls: fileListUrls, selectedId: self.selectedId, selectedGroupID: selectedGroupID ?? 0)
                    router.pushViewController(viewController: controller)
                    self.isScreenPresented = false
                }
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
    }
}
