//
//  PhotoPrintStatusPopup.swift
//  Depo
//
//  Created by Ozan Salman on 27.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintStatusPopup: BasePopUpController {
    
    @IBOutlet weak var exitImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelUnborder.image
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.orderDetailPopupName)
        }
    }
    
    @IBOutlet weak var lineLabel: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.lightGrayColor.color
        }
    }
    
    @IBOutlet weak var containerView: UIView! {
        willSet {
            newValue.backgroundColor = .white
            newValue.layer.cornerRadius = 8
            newValue.addRoundedShadows(cornerRadius: 15, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        willSet {
            newValue.layer.cornerRadius = 8
            newValue.contentMode = .center
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet weak var statusIcon: UIImageView! {
        willSet {
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = AppColor.forgetPassTextGreen.color
            newValue.text = localized(.orderApproved)
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var orderNoLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.printPopupGray.color
        }
    }
    
    @IBOutlet weak var cargoFirmNameLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.printPopupGray.color
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var cargoNoLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.printPopupGray.color
            newValue.isHidden = true
        }
    }
    
    @IBOutlet weak var createDateLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.printPopupGray.color
        }
    }
    
    private var item: GetOrderResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
        
        let status = getStatus(status: item?.status ?? "")
        dateLabel.text = dateConverter(epochTimeInMilliseconds: item?.createdDate ?? 0, type: 1)
        statusLabel.text = status.titleText
        infoLabel.text = status.detailText
        createDateLabel.text = dateConverter(epochTimeInMilliseconds: item?.itemLastStatusUpdateDate ?? 0, type: 2)
        orderNoLabel.text = String(format: localized(.printOrderNumber), item?.requestID ?? "")
        
        statusLabel.textColor = status.titleLabelColor
        statusIcon.image = status.statusImage
        statusIcon.isHidden = status.statusImageIsHidden
        
        if item?.cargoTrackingNumber != nil {
            cargoFirmNameLabel.isHidden = false
            cargoNoLabel.isHidden = false
            cargoFirmNameLabel.text = String(format: localized(.printCargoName), item?.cargoFirmName ?? "")
            cargoNoLabel.text = String(format: localized(.printCargoNumber), item?.cargoTrackingNumber ?? "")
        }
        

        guard let urlString = item?.affiliateOrderDetails.first?.fileInfo.tempDownloadURL else { return }
        let url = URL(string: urlString)
        imageView.contentMode = .scaleToFill
        imageView.sd_setImage(with: url)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: false)
    }
}

extension PhotoPrintStatusPopup {
    static func with(photoPrintData: GetOrderResponse) -> PhotoPrintStatusPopup {
        let vc = controllerWith(photoPrintData: photoPrintData)
        return vc
    }
    
    private static func controllerWith(photoPrintData: GetOrderResponse?) -> PhotoPrintStatusPopup {
        let vc = PhotoPrintStatusPopup(nibName: "PhotoPrintStatusPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.item = photoPrintData
        return vc
    }
}


extension PhotoPrintStatusPopup {
    private func dateConverter(epochTimeInMilliseconds: Int, type: Int) -> String {
        let epochTimeInSeconds = TimeInterval(epochTimeInMilliseconds) / 1000
        let date = Date(timeIntervalSince1970: epochTimeInSeconds)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .short
        if type == 1 {
            dateFormatter.dateFormat = "MMMM YYYY"
        } else if type == 2 {
            dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        }
        
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
        }
        return .newOrder
    }
}
