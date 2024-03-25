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
    
    private let service = BestSceneService()
    
    private lazy var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColor.background.color
        view.layer.cornerRadius = 16
        return view
    }()
    
    let snCollectionViewLayout = SNCollectionViewLayout()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AppColor.background.color
        view.layer.cornerRadius = 12
        
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        return view
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "action_info")
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = localized(.deleteInfo)
        label.textColor = AppColor.label.color
        label.font = .appFont(.medium, size: 14)
        label.textAlignment = .left
        
        return label
    }()
    
    let deleteSelectedItemButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized(.deleteForSelected), for: .normal)
        button.backgroundColor = AppColor.darkBlueColor.color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 21
        button.clipsToBounds = true
        button.layer.borderWidth = 1.0
        button.layer.borderColor = AppColor.darkBlueColor.cgColor
        button.titleLabel?.font = .appFont(.medium, size: 14)
        button.addTarget(self, action: #selector(tappedDeleteButton), for: .touchUpInside)
        return button
    }()
    
    let keepAllItemButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized(.keepEverything), for: .normal)
        button.setTitleColor(AppColor.darkBlueColor.color, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 21
        button.clipsToBounds = true
        button.layer.borderWidth = 1.0
        button.layer.borderColor = AppColor.darkBlueColor.cgColor
        button.titleLabel?.font = .appFont(.medium, size: 14)
        button.addTarget(self, action: #selector(tappedKeepItemButton), for: .touchUpInside)
        return button
    }()
    
    var coverPhotoUrl: String?
    var fileListUrls: [String] = []
    
    var selectedId: [Int]
    var selectedGroupID: Int?
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.bestscenediscovercardtitle))
        
        snCollectionViewLayout.fixedDivisionCount = 4
        snCollectionViewLayout.delegate = self
        collectionView.collectionViewLayout = snCollectionViewLayout
        snCollectionViewLayout.itemSpacing = 8
        snCollectionViewLayout.scrollDirection = .vertical
        
        setupLayout()

//        print("Güncel dizi 😎: \(self.selectedId)")
    }
    
    init(coverPhotoUrl: String, fileListUrls: [String], selectedId: [Int], selectedGroupID: Int) {
        self.coverPhotoUrl = coverPhotoUrl
        self.fileListUrls = fileListUrls
        self.selectedId = selectedId
        self.selectedGroupID = selectedGroupID
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
        
        view.backgroundColor = AppColor.background.color
                
        view.addSubview(customView)
        customView.addSubview(collectionView)
        customView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(deleteSelectedItemButton)
        containerView.addSubview(keepAllItemButton)
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: view.topAnchor),
            customView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customView.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: containerView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: customView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height / 3)
        ])
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 38),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            deleteSelectedItemButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            deleteSelectedItemButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50),
            deleteSelectedItemButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            deleteSelectedItemButton.heightAnchor.constraint(equalToConstant: 42),
            
            keepAllItemButton.topAnchor.constraint(equalTo: deleteSelectedItemButton.bottomAnchor, constant: 12),
            keepAllItemButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50),
            keepAllItemButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
            keepAllItemButton.heightAnchor.constraint(equalTo: deleteSelectedItemButton.heightAnchor),
        ])
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
                        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
                
        collectionView.backgroundColor = AppColor.background.color
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(BestSceneAllGroupSortedCollectionViewCell.self, forCellWithReuseIdentifier: "BestSceneAllGroupSortedCollectionViewCell")
        return collectionView
    }()
    
    @objc func tappedDeleteButton() {
        let vc = BestSceneSuccessPopUp.with()
        vc.onYesButtonTapped = { [weak self] in
            guard let self = self else { return }
            service.deleteSelectedPhotos(groupId: self.selectedGroupID ?? 0, photoIds: self.selectedId) { response in
                switch response {
                case .success():
                    print("Photos deleted successfully")
                case .failed(let error):
                    print(error.localizedDescription)
                }
            }
        }
        vc.open()
    }
    
     @objc func tappedKeepItemButton() {
         service.keepAllPhotosInGroup(groupId: nil, photoIds: []) { response in
             self.collectionView.reloadData()
         }
     }
}

extension BestSceneAllGroupSortedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SNCollectionViewLayoutDelegate, BestSceneCellDelegate {
    
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
        
        let photoUrl = indexPath.row == 0 ? coverPhotoUrl : fileListUrls[indexPath.row - 1]
        cell.imageView.sd_setImage(with: URL(string: photoUrl ?? ""))
        
        cell.selectedId = self.selectedId
        cell.selectedGroupID = self.selectedGroupID
               
        cell.uniqueId = self.selectedId[indexPath.row]
        
        cell.delegate = self
        
        return cell
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
    
    func didTapTickImage(selectedId: Int, isSelected: Bool) {
        var deletedIndex: Int = -1
        
        if isSelected {
            if !self.selectedId.contains(selectedId) {
                self.selectedId.append(selectedId)
            }
        } else {
            for(index, value) in self.selectedId.enumerated() {
                if value == selectedId {
                    deletedIndex = index
                }
            }
            if deletedIndex > -1 {
                self.selectedId.remove(at: deletedIndex)
            }
        }
//        print("😎 Güncel Seçilen ID'ler: \(self.selectedId)")
    }
}

