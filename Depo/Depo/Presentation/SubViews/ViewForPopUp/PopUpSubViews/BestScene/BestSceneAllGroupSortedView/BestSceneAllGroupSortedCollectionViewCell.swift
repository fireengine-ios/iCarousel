//
//  BestSceneAllGroupSortedCollectionViewCell.swift
//  Depo
//
//  Created by Rustam Manafov on 04.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit

protocol BestSceneCellDelegate: AnyObject {
    func didTapTickImage(selectedId: Int, isSelected: Bool)
}

class BestSceneAllGroupSortedCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    weak var delegate: BestSceneCellDelegate?
    
    var selectedId: [Int]
    var selectedGroupID: Int?
    
    let uniqueId: Int?
        
    var bigTickViewTopConstraint: NSLayoutConstraint!
    var bigTickViewLeadingConstraint: NSLayoutConstraint!
    var bigTickViewWidthConstraint: NSLayoutConstraint!
    var bigTickViewHeightConstraint: NSLayoutConstraint!
    
    var smallTickViewWidthConstraint: NSLayoutConstraint!
    var smallTickViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var bigTickView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.gray
        view.layer.cornerRadius = 6
        return view
    }()
    
    private lazy var smallTickView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 4
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTick))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var tickImage: UIImageView = {
        let tickImage = UIImageView()
        tickImage.translatesAutoresizingMaskIntoConstraints = false
        return tickImage
    }()
    
    let titleLabelView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = localized(.bestPhoto)
        label.textColor = .white
        label.font = UIFont(name: "TurkcellSaturaMed", size: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        self.selectedId = []
        self.uniqueId = 0
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedId = []
        self.uniqueId = 0
        super.init(coder: aDecoder)
        setupViews()
    }

    @objc func didTapTick() {
        isSelected = !isSelected
        
        if let id = self.uniqueId {
               delegate?.didTapTickImage(selectedId: id, isSelected: isSelected)
           }
        
        if tickImage.isHidden {
            tickImage.image = UIImage(named: "iconCheckboxCheckFill")
        }
        tickImage.isHidden = !tickImage.isHidden
    }

    
    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabelView)
        contentView.addSubview(bigTickView)
        bigTickView.addSubview(smallTickView)
        smallTickView.addSubview(tickImage)
        titleLabelView.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            titleLabelView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -4),
            titleLabelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabelView.widthAnchor.constraint(equalToConstant: 90),
            titleLabelView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleLabelView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: titleLabelView.centerYAnchor)
        ])
        
        bigTickViewTopConstraint = bigTickView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 4)
        bigTickViewLeadingConstraint = bigTickView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 4)
        bigTickViewWidthConstraint = bigTickView.widthAnchor.constraint(equalToConstant: 32)
        bigTickViewHeightConstraint = bigTickView.heightAnchor.constraint(equalToConstant: 32)
        
        NSLayoutConstraint.activate([
            bigTickViewTopConstraint,
            bigTickViewLeadingConstraint,
            bigTickViewWidthConstraint,
            bigTickViewHeightConstraint
        ])
        
        smallTickViewWidthConstraint = smallTickView.widthAnchor.constraint(equalToConstant: 18)
        smallTickViewHeightConstraint = smallTickView.heightAnchor.constraint(equalToConstant: 18)
        
        NSLayoutConstraint.activate([
            smallTickView.leadingAnchor.constraint(equalTo: bigTickView.leadingAnchor, constant: 3),
            smallTickView.trailingAnchor.constraint(equalTo: bigTickView.trailingAnchor, constant: -3),
            smallTickView.topAnchor.constraint(equalTo: bigTickView.topAnchor, constant: 3),
            smallTickView.bottomAnchor.constraint(equalTo: bigTickView.bottomAnchor, constant: -3),
            smallTickViewWidthConstraint,
            smallTickViewHeightConstraint
        ])
        
        NSLayoutConstraint.activate([
            tickImage.centerXAnchor.constraint(equalTo: smallTickView.centerXAnchor),
            tickImage.centerYAnchor.constraint(equalTo: smallTickView.centerYAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()
        configureGradientTitleLabelView()
    }
    
    func configureTickViews(forFirstCell isFirstCell: Bool) {
        if isFirstCell {
            bigTickViewWidthConstraint.constant = 32
            bigTickViewHeightConstraint.constant = 32
        } else {
            bigTickViewWidthConstraint.constant = 20
            bigTickViewHeightConstraint.constant = 20
        }
        smallTickViewWidthConstraint.constant = bigTickViewWidthConstraint.constant - 6
        smallTickViewHeightConstraint.constant = bigTickViewHeightConstraint.constant - 6
        layoutIfNeeded()
    }
    
    func configureBorder(forFirstCell isFirstCell: Bool) {
        contentView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        if isFirstCell {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = contentView.bounds
            gradientLayer.colors = [
                UIColor(red: 238/255.0, green: 69/255.0, blue: 84/255.0, alpha: 1).cgColor,
                UIColor(red: 255/255.0, green: 143/255.0, blue: 41/255.0, alpha: 1).cgColor,
                UIColor(red: 255/255.0, green: 200/255.0, blue: 83/255.0, alpha: 1).cgColor
            ]
            
            gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
            
            let shape = CAShapeLayer()
            shape.lineWidth = 4
            shape.path = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
            shape.strokeColor = UIColor.black.cgColor
            shape.fillColor = nil
            
            gradientLayer.mask = shape
            
            contentView.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    func configureGradientTitleLabelView() {
        titleLabelView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
                
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = titleLabelView.bounds
        gradientLayer.colors = [
            UIColor(red: 238/255.0, green: 69/255.0, blue: 84/255.0, alpha: 1).cgColor,
            UIColor(red: 255/255.0, green: 143/255.0, blue: 41/255.0, alpha: 1).cgColor,
            UIColor(red: 255/255.0, green: 200/255.0, blue: 83/255.0, alpha: 1).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        
        titleLabelView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func configureTickImage(forFirstCell isFirstCell: Bool) {
        tickImage.isHidden = isFirstCell
        if isFirstCell {
            tickImage.image = UIImage(named: "iconCheckboxCheckFill")
        } else {
            tickImage.image = UIImage(named: "iconCheckboxCheckFill")
        }
    }
}
