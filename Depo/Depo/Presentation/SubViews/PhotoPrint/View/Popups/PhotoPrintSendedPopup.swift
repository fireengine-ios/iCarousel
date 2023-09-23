//
//  PhotoPrintSendedPopup.swift
//  Depo
//
//  Created by Ozan Salman on 21.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintSendedPopup: BasePopUpController {
    
    @IBOutlet weak var exitImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelUnborder.image
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
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 8
            
        }
    }
    
    @IBOutlet weak var dateLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.label.color
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
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.darkBlueColor.color
            newValue.numberOfLines = 2
            newValue.text = localized(.sentPrintInfoPopupTitle)
        }
    }
    
    @IBOutlet weak var addressLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 4
        }
    }
    
    private var address: AddressResponse?
    private var editedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
        
        imageView.image = editedImages[0]
        let myTime = Date()
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        dateLabel.text = format.string(from: myTime)
        
        addressLabel.text = String(format: localized(.sendPrintPopupAddress), address?.neighbourhood ?? "", address?.street ?? "", address?.buildingNumber ?? 0, address?.apartmentNumber ?? 0, address?.addressDistrict.name ?? "", address?.addressCity.name ?? "", address?.postalCode ?? 0)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}

extension PhotoPrintSendedPopup {
    static func with(address: AddressResponse?, editedImages: [UIImage]? = []) -> PhotoPrintSendedPopup {
        let vc = controllerWith(address: address, editedImages: editedImages)
        return vc
    }
    
    private static func controllerWith(address: AddressResponse?, editedImages: [UIImage]? = []) -> PhotoPrintSendedPopup {
        let vc = PhotoPrintSendedPopup(nibName: "PhotoPrintSendedPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.address = address
        vc.editedImages = editedImages ?? []
        return vc
    }
}
