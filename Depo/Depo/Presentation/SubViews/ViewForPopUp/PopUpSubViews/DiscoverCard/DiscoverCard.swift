//
//  DiscoverCard.swift
//  Lifebox
//
//  Created by Rustam Manafov on 13.02.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

class DiscoverCard: BaseCardView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private lazy var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Best Scene Selection"
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont(name: "GTAmerica-Medium", size: 16)
        return label
    }()
    
    private lazy var cancelIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cancel_icon")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.50, green: 0.74, blue: 0.84, alpha: 1.00)
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Seri fotoğraflarının arasında en iyi fotoğrafını belirle"
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 2
        label.font = UIFont(name: "GTAmerica-Bold", size: 14)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 145, height: 145)
        layout.sectionInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DiscoverCollectionViewCell.self, forCellWithReuseIdentifier: "DiscoverCollectionViewCell")
        return collectionView
    }()
    
    private lazy var allPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tüm Seri Fotoğrafları Gör", for: .normal)
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 14)
        button.tintColor = UIColor(red: 0.00, green: 0.48, blue: 0.67, alpha: 1.00)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         print("⚠️⛔️")
        setupLayout()
        setupConstraints()
     }
     
     required init?(coder: NSCoder) {
         super.init(coder: coder)
         
         setupLayout()
         setupConstraints()
     }
    
    override func configurateView() {
           super.configurateView()
   
        canSwipe = false
    }
    
    func configurateWithType(viewType: OperationType) {
        print("⚠️")
//        titleLabel.text = "fkjnsdf"
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .discoverCard)
    }
    
    
    private func setupLayout() {
        self.addSubview(customView)
        customView.addSubview(titleLabel)
        customView.addSubview(cancelIcon)
        customView.addSubview(separatorView)
        customView.addSubview(descriptionLabel)
        customView.addSubview(collectionView)
        customView.addSubview(allPictureButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            customView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            customView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            customView.widthAnchor.constraint(equalToConstant: 359),
            customView.heightAnchor.constraint(equalToConstant: 354),
            
            titleLabel.topAnchor.constraint(equalTo: customView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            cancelIcon.topAnchor.constraint(equalTo: customView.topAnchor, constant: 16),
            cancelIcon.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            cancelIcon.widthAnchor.constraint(equalToConstant: 24),
            cancelIcon.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 19.5),
            separatorView.leadingAnchor.constraint(equalTo: customView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: customView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 15.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 48),
            
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: 0),
            collectionView.heightAnchor.constraint(equalToConstant: 145),
            
            allPictureButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 18),
            allPictureButton.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 16),
            allPictureButton.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: -16),
            allPictureButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    @objc func imageTapped() {
        print("⚠️")
    }
    
    @objc func buttonTapped() {
        print("⛔️")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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
}
