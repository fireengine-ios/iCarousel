//
//  BestSceneSuccessPopUp.swift
//  Lifebox
//
//  Created by Rustam Manafli on 13.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

typealias BestSceneSuccessPopUpButtonHandler = (_: BestSceneSuccessPopUp) -> Void

final class BestSceneSuccessPopUp: BasePopUpController {
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.image = UIImage(named: "customPopUpInfo")
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.forgetPassTimer.color
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet private weak var yesButton: UIButton! {
        willSet {
            newValue.setTitle(localized(TextConstants.faceImageYes), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
    
    @IBOutlet private weak var dismissButton: UIButton! {
        willSet {
            newValue.setTitle(localized(TextConstants.createStoryPhotosCancel), for: .normal)
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

        titleLabel.text = localized(TextConstants.contactBackupHistoryDeletePopUpTitle)
        descriptionLabel.text = localized(TextConstants.contactConfirmDeleteTitle)
    }
    
    @IBAction func yesButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            let router = RouterVC()
            let controller = router.bestSceneAllGroupController()
            router.pushViewController(viewController: controller)
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
}

// MARK: - Init
extension BestSceneSuccessPopUp {
    static func with() -> BestSceneSuccessPopUp {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> BestSceneSuccessPopUp {
        let vc = BestSceneSuccessPopUp(nibName: "BestSceneSuccessPopUp", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        return vc
    }
}
