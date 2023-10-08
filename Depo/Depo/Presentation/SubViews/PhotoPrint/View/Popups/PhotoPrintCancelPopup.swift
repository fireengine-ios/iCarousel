//
//  PhotoPrintCancelPopup.swift
//  Depo
//
//  Created by Ozan Salman on 15.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

typealias PhotoPrintCancelPopupButtonHandler = (_: PhotoPrintCancelPopup) -> Void

final class PhotoPrintCancelPopup: BasePopUpController {
    
    @IBOutlet private weak var exitImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelUnborder.image
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.image = Image.popupErrorOrange.image
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.forgetPassTimer.color
            newValue.text = localized(.printCancelPopupQuestion)
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.printCancelPopupInfo)
            newValue.numberOfLines = 3
            newValue.sizeToFit()
            newValue.adjustsFontSizeToFitWidth = true
        }
    }
    
    @IBOutlet weak var continueButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.printContinueButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.cancel, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(AppColor.darkBlueColor.color, for: .normal)
            newValue.backgroundColor = .white
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: .navigationBack, object: nil)
        })
    }
    
    @IBAction func cancelPhotoTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
}

// MARK: - Init
extension PhotoPrintCancelPopup {
    static func with() -> PhotoPrintCancelPopup {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> PhotoPrintCancelPopup {
        let vc = PhotoPrintCancelPopup(nibName: "PhotoPrintCancelPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

