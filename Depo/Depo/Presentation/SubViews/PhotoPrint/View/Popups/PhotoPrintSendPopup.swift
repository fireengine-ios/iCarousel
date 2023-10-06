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
            newValue.numberOfLines = 5
            newValue.adjustsFontSizeToFitWidth()
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
    private var editedImages = [UIImage]()
    
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
        updateUserInfo()
    }
    
    private func updateUserInfo() {
        showSpinner()
        let accountService = AccountService()
        accountService.info(success: { [weak self] response in
            guard let response = response as? AccountInfoResponse else {
                assertionFailure()
                return
            }
            DispatchQueue.toMain {
                SingletonStorage.shared.accountInfo = response
                let sendRemaining = SingletonStorage.shared.accountInfo?.photoPrintSendRemaining ?? 0
                if sendRemaining == 0 {
                    self?.hideSpinner()
                    let vc = PhotoPrintNoRightPopup.with()
                    vc.open()
                } else {
                    self?.sendEditedImages()
                }
            }
        }) { error in }
    }
    
    private func sendEditedImages() {
        var sendData = [WrapData]()
        for image in editedImages {
            let imageData = image.jpegData(compressionQuality: 1.0)!
            let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
            let wrapData = WrapData(imageData: imageData, isLocal: true)
            wrapData.patchToPreview = PathForItem.remoteUrl(url)
            sendData.append(wrapData)
        }
        
        UploadService.default.uploadFileList(items: sendData, uploadType: .upload, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, isPhotoPrint: true,
                                             success: { },
                                             fail: {value in },
                                             returnedUploadOperation: { [weak self] values in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    self?.setSendedPhotosFileUuid(returnOperation: values ?? [])
                                                }
            
        })
    }
    
    private func setSendedPhotosFileUuid(returnOperation: [UploadOperation]) {
        var fileUuidList = [String]()
        for value in returnOperation {
            fileUuidList.append(value.inputItem.uuid)
        }
        createOrder(fileUuidList: fileUuidList)
    }
    
    private func createOrder(fileUuidList: [String]) {
        let service = PhotoPrintService()
        service.photoPrintCreateOrder(addressId: address?.id ?? 0, fileUuidList: fileUuidList) { [weak self] result in
            switch result {
            case .success(_):
                self?.hideSpinner()
                self?.dismiss(animated: false, completion: {
                    self?.updateAccountInfoForPhotoPrint()
                    let vc = PhotoPrintSendedPopup.with(address: self?.address, editedImages: self?.editedImages)
                    vc.openWithBlur()
                })
            case .failed(let error):
                let errorMessage = ServerValueError(value: error.localizedDescription, code: error.errorCode).errorDescription ?? ""
                UIApplication.showErrorAlert(message: errorMessage)
                self?.hideSpinner()
                break
            }
        }
    }
    
    private func updateAccountInfoForPhotoPrint() {
        let sendRemaining = SingletonStorage.shared.accountInfo?.photoPrintSendRemaining ?? 0
        let maxSelection = SingletonStorage.shared.accountInfo?.photoPrintMaxSelection ?? 0
        SingletonStorage.shared.accountInfo?.photoPrintSendRemaining = sendRemaining > 0 ? sendRemaining - 1 : 0
        SingletonStorage.shared.accountInfo?.photoPrintMaxSelection = (maxSelection - editedImages.count) >= 0 ? maxSelection - editedImages.count : 0
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
    static func with(address: AddressResponse?, editedImages: [UIImage]? = []) -> PhotoPrintSendPopup {
        let vc = controllerWith(address: address, editedImages: editedImages)
        return vc
    }
    
    private static func controllerWith(address: AddressResponse?, editedImages: [UIImage]? = []) -> PhotoPrintSendPopup {
        let vc = PhotoPrintSendPopup(nibName: "PhotoPrintSendPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.setAddressText(address: address)
        vc.editedImages = editedImages ?? []
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
