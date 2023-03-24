//
//  CreateCollageTableViewCell.swift
//  Lifebox
//
//  Created by Ozan Salman on 3.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

protocol CreateCollageTableViewCellDelegate: AnyObject {
    func onSeeAllButton(for section: CollageTemplateSections)
    func naviateToCollageTemplateDetail(collageTemplate: CollageTemplateElement)
}

final class CreateCollageTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = AppColor.background.color
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var seeAllButton: UIButton = {
        let view = UIButton()
        view.setTitleColor(AppColor.label.color, for: .normal)
        view.titleLabel?.font = .appFont(.light, size: 14)
        view.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 154, height: 154)
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(CreateCollageCollectionViewCell.self, forCellWithReuseIdentifier: "CreateCollageCollectionViewCell")
        view.backgroundColor = AppColor.background.color
        return view
    }()
    
    private var collageTemplateModel: CollageTemplate?
    weak var delegate: CreateCollageTableViewCellDelegate?
    private var currentSection: CollageTemplateSections?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
        configureTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
        configureTableView()
    }
    
    func configure(model: CollageTemplate, section: CollageTemplateSections) {
        currentSection = section
        collageTemplateModel = model
        titleLabel.text = section.title
        seeAllButton.setTitle(section.seeAllTitle, for: .normal)
        collectionView.reloadData()

    }
    
    private func configureTableView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc func seeAllButtonTapped(sender: UIButton) {
        if let currentSection = currentSection {
            delegate?.onSeeAllButton(for: currentSection)
        }
    }
    
}

extension CreateCollageTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collageTemplateModel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateCollageCollectionViewCell", for: indexPath) as? CreateCollageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(collageTemplateModel: (collageTemplateModel?[safe: indexPath.row])!)
        return cell
    }
}

extension CreateCollageTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collageTemplate = collageTemplateModel?[indexPath.row] else {
            return
        }
        delegate?.naviateToCollageTemplateDetail(collageTemplate: collageTemplate)
    }
}

extension CreateCollageTableViewCell {
    private func setLayout() {
        contentView.backgroundColor = AppColor.background.color
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).activate()
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4).activate()
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3).activate()
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4).activate()
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).activate()
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).activate()
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).activate()
        titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).activate()
        
        containerView.addSubview(seeAllButton)
        seeAllButton.translatesAutoresizingMaskIntoConstraints = false
        seeAllButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).activate()
        seeAllButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).activate()
        seeAllButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).activate()
        
        containerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).activate()
        collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).activate()
        collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).activate()
        collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6).activate()
        
    }
}

