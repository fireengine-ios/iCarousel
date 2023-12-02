//
//  PhotoPrintSeeAllTableViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 26.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintSeeAllTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = AppColor.background.color
        view.addRoundedShadows(cornerRadius: 16, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var dateLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.spacing = 5
        return view
    }()
    
    private lazy var statusImageView: UIImageView = {
        let view = UIImageView()
        view.isHidden = true
        return view
    }()
    
    private lazy var statusLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.regular, size: 12)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(PhotoPrintSeeAllCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoPrintSeeAllCollectionViewCell")
        view.backgroundColor = AppColor.background.color
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var photoPrintData: GetOrderResponse?
    let numberOfСellInRow: Int = 5
    let minSeparatorSize: CGFloat = 2
    var collectionViewW: CGFloat = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
        configureCollectionView()
    }
    
    func configure(item: GetOrderResponse?) {
        let status = getStatus(status: item?.status ?? "")
        containerView.layer.borderColor = status.titleLabelColor.cgColor
        dateLabel.text = dateConverter(epochTimeInMilliseconds: item?.createdDate ?? 0)
        statusImageView.isHidden = false
        statusImageView.image = status.statusImage
        statusLabel.text = status.titleText
        statusLabel.textColor = status.titleLabelColor
        photoPrintData = item
        collectionView.reloadData()
    }
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension PhotoPrintSeeAllTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoPrintData?.affiliateOrderDetails.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPrintSeeAllCollectionViewCell", for: indexPath) as? PhotoPrintSeeAllCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(urlString: photoPrintData?.affiliateOrderDetails[indexPath.row].fileInfo.metadata.thumbnailMedium ?? "")
        return cell
    }
}

extension PhotoPrintSeeAllTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minSeparatorSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minSeparatorSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: calculateLinearDimensionsForCell(), height: calculateLinearDimensionsForCell())
    }
    
    private func calculateLinearDimensionsForCell() -> CGFloat {
        let w = collectionView.frame.size.width
        let cellW = (w - minSeparatorSize * CGFloat(numberOfСellInRow) + minSeparatorSize) / CGFloat(numberOfСellInRow)
        return cellW
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoPrintStatusPopup.with(photoPrintData: photoPrintData!, index: indexPath.row)
        vc.open()
    }
}

extension PhotoPrintSeeAllTableViewCell {
    private func setLayout() {
        contentView.backgroundColor = AppColor.background.color
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).activate()
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).activate()
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).activate()
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).activate()
        containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 165).activate()
        
        containerView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12).activate()
        dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).activate()
        dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).activate()
        dateLabel.heightAnchor.constraint(equalToConstant: 24).activate()
        
        containerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12).activate()
        collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).activate()
        collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).activate()
        collectionView.heightAnchor.constraint(equalToConstant: 80).activate()
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8).activate()
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).activate()
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).activate()
        
        stackView.addArrangedSubview(statusImageView)
        
        stackView.addArrangedSubview(statusLabel)
        
//        containerView.addSubview(statusLabel)
//        statusLabel.translatesAutoresizingMaskIntoConstraints = false
//        statusLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8).activate()
//        statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).activate()
//        statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12).activate()
    }
}

extension PhotoPrintSeeAllTableViewCell {
    private func dateConverter(epochTimeInMilliseconds: Int) -> String {
        let epochTimeInSeconds = TimeInterval(epochTimeInMilliseconds) / 1000
        let date = Date(timeIntervalSince1970: epochTimeInSeconds)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = "MMMM YYYY"
        
        return dateFormatter.string(from: date)
    }
    
    private func getStatus(status: String) -> OrderStatus {
        if status == "NEW_ORDER" {
            return .newOrder
        } else if status == "IN_PROGRESS" {
            return .inProgress
        } else if status == "DELIVERED" {
            return .delivered
        } else if status == "UNDELIVERED" {
            return .unDelivered
        } else if status == "DELIVERED_CARGO" {
            return .deliveredCargo
        } else if status == "ORDER_NOT_DELIVERED" {
            return .orderNotDelivered
        }
        return .newOrder
    }
}
