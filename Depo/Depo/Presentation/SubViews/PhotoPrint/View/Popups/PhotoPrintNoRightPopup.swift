//
//  PhotoPrintNoRightPopup.swift
//  Depo
//
//  Created by Ozan Salman on 14.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

typealias PhotoPrintNoRightPopupButtonHandler = (_: PhotoPrintNoRightPopup) -> Void

final class PhotoPrintNoRightPopup: BasePopUpController {
    
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
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.noRightPrintPopupTitle)
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.noRightPrintPopupInfo)
            newValue.numberOfLines = 3
            newValue.sizeToFit()
            newValue.adjustsFontSizeToFitWidth = true
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.ok, for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: {
            print("aaaaaaaaaaaaaaaa")
        })
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
}

// MARK: - Init
extension PhotoPrintNoRightPopup {
    static func with() -> PhotoPrintNoRightPopup {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> PhotoPrintNoRightPopup {
        let vc = PhotoPrintNoRightPopup(nibName: "PhotoPrintNoRightPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}

