//
//  PhotoPrintSendPopup.swift
//  Depo
//
//  Created by Ozan Salman on 17.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintSendPopup: BasePopUpController {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.text = localized(.sendPrintPopupTitle)
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var adressLabel: UILabel! {
        willSet {
            newValue.text = localized(.sendPrintPopupAddress)
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 4
        }
    }
    
    @IBOutlet weak var infoImageView: UIImageView!  {
        willSet {
            newValue.image = Image.iconPrintInfoOrange.image
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel!  {
        willSet {
            newValue.text = localized(.sendPrintPopupInfo)
            newValue.font = .appFont(.medium, size: 12)
            newValue.textColor = AppColor.profileInfoOrange.color
            newValue.numberOfLines = 2
            newValue.textAlignment = .left
        }
    }
    
    @IBOutlet weak var sendButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.sendPrintButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.borderLightGray.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.borderLightGray.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.borderLightGray.cgColor
        }
    }
    
    @IBOutlet weak var changeAdressLabel: UILabel!  {
        willSet {
            newValue.text = localized(.addAddress)
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 1
        }
    }
    
    private var address: AddressResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTapped()
        setAddressLabel()
        NotificationCenter.default.addObserver(self,selector: #selector(finishAddressEntry(_:)),name: .addressBack, object: nil)
    }
    
    @objc func finishAddressEntry(_ notification:Notification) {
        if let local = notification.userInfo?["address"] as? AddressResponse {
            address = local
            adressLabel.text = String(format: localized(.sendPrintPopupAddress), address?.neighbourhood ?? "", address?.street ?? "", address?.buildingNumber ?? 0, address?.apartmentNumber ?? 0, address?.addressDistrict.name ?? "", address?.addressCity.name ?? "", address?.postalCode ?? 0)
            
            changeAdressLabel.text = localized(.updateAddress)
            enableSendButton(isEnable: true)
        }
    }
    
    private func setAddressLabel() {
        if address == nil {
            adressLabel.text = localized(.sendPrintPopupNoAddress)
            changeAdressLabel.text = localized(.addAddress)
            enableSendButton(isEnable: false)
        } else {
            adressLabel.text = String(format: localized(.sendPrintPopupAddress), address?.neighbourhood ?? "", address?.street ?? "", address?.buildingNumber ?? 0, address?.apartmentNumber ?? 0, address?.addressDistrict.name ?? "", address?.addressCity.name ?? "", address?.postalCode ?? 0)
            changeAdressLabel.text = localized(.updateAddress)
            enableSendButton(isEnable: true)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissPopup()
    }
    
    @objc private func changeAddressTapped() {
        dismiss(animated: false, completion: {
            let vc = PhotoPrintAddAdressPopup.with(address: self.address)
            vc.openWithBlur()
        })
        
    }
    
    private func enableSendButton(isEnable: Bool) {
        if isEnable {
            sendButton.backgroundColor = AppColor.darkBlueColor.color
            sendButton.layer.borderColor = AppColor.darkBlueColor.cgColor
            sendButton.isUserInteractionEnabled = true
            
            cancelButton.backgroundColor = .white
            cancelButton.layer.borderColor = AppColor.darkBlueColor.cgColor
            cancelButton.isUserInteractionEnabled = true
            cancelButton.setTitleColor(AppColor.darkBlueColor.color, for: .normal)
        } else {
            sendButton.backgroundColor = AppColor.borderLightGray.color
            sendButton.layer.borderColor = AppColor.borderLightGray.cgColor
            sendButton.isUserInteractionEnabled = false
            
            cancelButton.backgroundColor = AppColor.borderLightGray.color
            cancelButton.layer.borderColor = AppColor.borderLightGray.cgColor
            cancelButton.isUserInteractionEnabled = true
            cancelButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func setAddressText(address: AddressResponse?) {
        if address == nil {
            self.address = nil
        } else {
            self.address = address
        }
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
}

extension PhotoPrintSendPopup {
    static func with(address: AddressResponse?) -> PhotoPrintSendPopup {
        let vc = controllerWith(address: address)
        return vc
    }
    
    private static func controllerWith(address: AddressResponse?) -> PhotoPrintSendPopup {
        let vc = PhotoPrintSendPopup(nibName: "PhotoPrintSendPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.setAddressText(address: address)
        return vc
    }
}

extension PhotoPrintSendPopup {
    private func setTapped() {
        changeAdressLabel.isUserInteractionEnabled = true
        let tapLabel = UITapGestureRecognizer(target: self, action: #selector(changeAddressTapped))
        changeAdressLabel.addGestureRecognizer(tapLabel)
    }
}
