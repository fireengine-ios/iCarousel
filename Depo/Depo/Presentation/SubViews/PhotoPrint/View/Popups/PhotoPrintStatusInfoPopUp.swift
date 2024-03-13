//
//  PhotoPrintStatusInfoPopUp.swift
//  Depo
//
//  Created by Rustam Manafov on 12.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

typealias PhotoPrintStatusInfoPopUpButtonHandler = (_: PhotoPrintStatusInfoPopUp) -> Void

final class PhotoPrintStatusInfoPopUp: BasePopUpController {
    
    @IBOutlet weak var exitImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelUnborder.image
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        willSet {
            newValue.image = UIImage(named: "customPopUpInfo")
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.forgetPassTimer.color
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet weak var selectButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.okButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let maxSelection = SingletonStorage.shared.accountInfo?.photoPrintMaxSelection ?? 0
        titleLabel.text = String(format: localized(.photoMaxSelectionTitleX), maxSelection)
        descriptionLabel.text = String(format: localized(.photoMaxSelectionBodyX), maxSelection)
                
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
    }
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}

// MARK: - Init
extension PhotoPrintStatusInfoPopUp {
    static func with() -> PhotoPrintStatusInfoPopUp {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> PhotoPrintStatusInfoPopUp {
        let vc = PhotoPrintStatusInfoPopUp(nibName: "PhotoPrintStatusInfoPopUp", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        return vc
    }
}
