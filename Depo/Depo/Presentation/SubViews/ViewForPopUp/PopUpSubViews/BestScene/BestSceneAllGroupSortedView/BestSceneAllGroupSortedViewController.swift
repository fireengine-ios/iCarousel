//
//  BestSceneAllGroupSortedViewController.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit
import SNCollectionViewLayout

class BestSceneAllGroupSortedViewController: BaseViewController {
    
    private lazy var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        view.layer.cornerRadius = 16
        return view
    }()
    
    let snCollectionViewLayout = SNCollectionViewLayout()
        
    var coverPhotoUrl: String?
    var fileListUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.bestscenediscovercardtitle))
        
        snCollectionViewLayout.fixedDivisionCount = 4
        snCollectionViewLayout.delegate = self
        collectionView.collectionViewLayout = snCollectionViewLayout
        snCollectionViewLayout.itemSpacing = 8
        snCollectionViewLayout.scrollDirection = .vertical
        
//        let popUp = BestScenePopUp.with()
//        popUp.open()
        
        setupLayout()
    }
    
    init(coverPhotoUrl: String, fileListUrls: [String]) {
        self.coverPhotoUrl = coverPhotoUrl
        self.fileListUrls = fileListUrls
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
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
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(BestSceneAllGroupSortedCollectionViewCell.self, forCellWithReuseIdentifier: "BestSceneAllGroupSortedCollectionViewCell")
        return collectionView
    }()
}

extension BestSceneAllGroupSortedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SNCollectionViewLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + fileListUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestSceneAllGroupSortedCollectionViewCell", for: indexPath) as! BestSceneAllGroupSortedCollectionViewCell
                
        cell.titleLabel.isHidden = indexPath.item != 0
        cell.titleLabelView.isHidden = indexPath.item != 0
        cell.configureTickViews(forFirstCell: indexPath.item == 0)
        cell.configureBorder(forFirstCell: indexPath.item == 0)
        cell.configureTickImage(forFirstCell: indexPath.item == 0)
        cell.configureTickImage(forFirstCell: indexPath.item == 0)
        
        let isFirstItem = indexPath.row == 0
        
        let photoUrl = indexPath.row == 0 ? coverPhotoUrl : fileListUrls[indexPath.row - 1]
        cell.imageView.sd_setImage(with: URL(string: photoUrl ?? ""))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("cell tapped")
    }
    
    func scaleForItem(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, atIndexPath indexPath: IndexPath) -> UInt {
        if indexPath.row == 0 {
            
            return 2
        }
        return 1
    }
    
    func itemFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return fixedDimension
    }
    
    func headerFlexibleDimension(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return 0
    }
}
