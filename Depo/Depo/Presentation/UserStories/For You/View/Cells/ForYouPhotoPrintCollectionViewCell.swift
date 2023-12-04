//
//  ForYouPhotoPrintCollectionViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 23.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

enum OrderStatus {
    case newOrder
    case inProgress
    case delivered
    case unDelivered
    case deliveredCargo
    case orderNotDelivered
    
    var titleText: String {
        switch self {
        case .newOrder: return localized(.orderApproved)
        case .inProgress: return localized(.orderInProgress)
        case .delivered: return localized(.orderDelivered)
        case .unDelivered: return localized(.orderUndelivered)
        case .deliveredCargo: return localized(.orderDeliveredCargo)
        case .orderNotDelivered: return localized(.orderNotDelivered)
        }
    }
    
    var detailText: String {
        switch self {
        case .newOrder: return localized(.orderApprovedDetail)
        case .inProgress: return localized(.orderInProgressDetail)
        case .delivered: return localized(.orderDeliveredDetail)
        case .unDelivered: return localized(.orderUndeliveredDetail)
        case .deliveredCargo: return localized(.orderDeliveredCargoDetail)
        case .orderNotDelivered: return localized(.orderNotDeliveredDetail)
        }
    }
    
    var titleLabelColor: UIColor {
        switch self {
        case .delivered: return AppColor.forgetPassTextGreen.color
        case .orderNotDelivered: return AppColor.forgetPassTextRed.color
        default: return AppColor.tealBlue.color
        }
    }
    
    var statusImageIsHidden: Bool {
        switch self {
        case .newOrder: return true
        case .inProgress: return true
        case .delivered: return false
        case .unDelivered: return true
        case .deliveredCargo: return false
        case .orderNotDelivered: return true
        }
    }
    
    var statusImage: UIImage {
        switch self {
        case .newOrder: return UIImage()
        case .inProgress: return UIImage()
        case .delivered: return Image.iconCheckGreen.image
        case .unDelivered: return UIImage()
        case .deliveredCargo: return Image.iconDelivery.image
        case .orderNotDelivered: return UIImage()
        }
    }
    
}

class ForYouPhotoPrintCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var bgView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.layer.borderWidth = 1
            newValue.layer.cornerRadius = 15
            newValue.layer.borderColor = AppColor.profileGrayColor.cgColor
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        }
    }
    
    @IBOutlet private weak var cardTitleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.medium, size: 12)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var cardThumbnailImage: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 15
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    @IBOutlet weak var thumbnailPlusImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleToFill
            newValue.image = Image.iconAddUnselectPlus.image
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var thumbnailPlusLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.printPopupGray.color
            newValue.font = .appFont(.medium, size: 12)
            newValue.numberOfLines = 2
            newValue.text = localized(.photoPrint)
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.tealBlue.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    private var printedPhotosData: GetOrderResponse?
    private let isPackage = SingletonStorage.shared.accountInfo?.photoPrintPackage ?? true
    private let sendRemaining = SingletonStorage.shared.accountInfo?.photoPrintSendRemaining ?? 0
    private let maxSelection = SingletonStorage.shared.accountInfo?.photoPrintMaxSelection ?? 0
    private var buttonDirectScreen: String = ""
    
    @IBAction private func onShowDetail(_ sender: UIButton) {
    }
    
    func configure(with item: GetOrderResponse) {
        printedPhotosData = item
        let status = getStatus(status: item.status)
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = status.titleLabelColor.cgColor
        cardTitleLabel.text = dateConverter(epochTimeInMilliseconds: item.createdDate)
        statusLabel.text = status.titleText
        statusLabel.textColor = status.titleLabelColor
        statusLabel.isHidden = false
        statusImageView.isHidden = status.statusImageIsHidden
        statusImageView.image = status.statusImage
        thumbnailPlusImage.isHidden = true
        thumbnailPlusLabel.isHidden = true
        cardThumbnailImage.contentMode = .scaleAspectFill
        cardThumbnailImage.layer.cornerRadius = 15
        let infoData = item.affiliateOrderDetails[0]
        guard let url = URL(string: infoData.fileInfo.metadata.thumbnailMedium) else {
            return
        }
        cardThumbnailImage.loadImageData(with: url, animated: false)
    }
    
    func configureWithOutData() {
        printedPhotosData = nil
        let format = DateFormatter()
        format.dateFormat = "MMMM"
        bgView.layer.borderWidth = 0
        if !isPackage {
            showPlusCard()
        } else {
            if sendRemaining > 0 {
                showPlusCard()
            } else if sendRemaining == 0 || maxSelection == 0 {
               showSeeAllCard()
            } else {
                showPlusCard()
            }
        }
        statusLabel.textColor = AppColor.tealBlue.color
        cardThumbnailImage.image = Image.collageThumbnail.image
        cardThumbnailImage.contentMode = .scaleAspectFit
        cardThumbnailImage.layer.cornerRadius = 15
        thumbnailPlusImage.isHidden = false
        thumbnailPlusLabel.isHidden = false
        statusImageView.isHidden = true
    }
    
    func showPlusCard() {
        statusLabel.isHidden = false
        statusLabel.text = String(format: localized(.foryouPrintBody), maxSelection)
        cardTitleLabel.text = localized(.foryouPrintTitle)
        thumbnailPlusLabel.text = localized(.photoPrint)
        thumbnailPlusImage.image = Image.iconAddUnselectPlus.image
        buttonDirectScreen = "NewPrint"
    }
    
    func showSeeAllCard() {
        statusLabel.isHidden = false
        statusLabel.text = localized(.printedPhotoCardInfoNoRight)
        cardTitleLabel.text = localized(.printedPhotoCardBodyNoRight)
        thumbnailPlusLabel.text = localized(.forYouSeeAll)
        thumbnailPlusImage.image = Image.iconNoRight.image
        buttonDirectScreen = "SeeAll"
    }
    
    @objc private func imageTapped() {
        var data = [GetOrderResponse]()
        data.append(printedPhotosData)
        let router = RouterVC()
        
        if buttonDirectScreen == "SeeAll" {
            let photoPrint = router.photoPrintForYouViewController()
            router.pushViewController(viewController: photoPrint)
            return
        }
        
        if data.count == 0 {
            let isHavePrintPackage = SingletonStorage.shared.accountInfo?.photoPrintPackage ?? false
            let sendRemaining = SingletonStorage.shared.accountInfo?.photoPrintSendRemaining ?? 0
            if !isHavePrintPackage {
                let vc = PhotoPrintNoPackagePopup.with()
                vc.open()
            } else if sendRemaining == 0 {
                let vc = PhotoPrintNoRightPopup.with()
                vc.open()
            } else {
                let vc = router.photoPrintSelectPhotos(popupShowing: true)
                router.pushViewController(viewController: vc, animated: false)
            }
        } else {
            let photoPrint = router.photoPrintForYouViewController(item: data)
            router.pushViewController(viewController: photoPrint)
        }
    }
    
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
