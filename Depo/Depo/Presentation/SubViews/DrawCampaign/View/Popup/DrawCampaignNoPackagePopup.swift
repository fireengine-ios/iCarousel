//
//  DrawCampaignNoPackagePopup.swift
//  Depo
//
//  Created by Ozan Salman on 25.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

typealias DrawCampaignNoPackagePopupButtonHandler = (_: DrawCampaignNoPackagePopup) -> Void

final class DrawCampaignNoPackagePopup: BasePopUpController {
    
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
            newValue.font = .appFont(.bold, size: 14)
            newValue.textColor = AppColor.profileInfoOrange.color
            newValue.text = localized(.drawWarningHeader)
            newValue.numberOfLines = 2
            newValue.sizeToFit()
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.forgetPassTimer.color
            newValue.text = localized(.drawWarningBody)
            newValue.numberOfLines = 3
            newValue.sizeToFit()
            newValue.adjustsFontSizeToFitWidth = true
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.drawPackageButton), for: .normal)
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
            let router = RouterVC()
            router.pushViewController(viewController: router.myStorage(usageStorage: nil))
        })
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
}

// MARK: - Init
extension DrawCampaignNoPackagePopup {
    static func with() -> DrawCampaignNoPackagePopup {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> DrawCampaignNoPackagePopup {
        let vc = DrawCampaignNoPackagePopup(nibName: "DrawCampaignNoPackagePopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}
