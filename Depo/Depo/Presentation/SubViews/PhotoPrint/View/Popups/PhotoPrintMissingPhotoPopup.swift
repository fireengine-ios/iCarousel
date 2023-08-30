//
//  PhotoPrintMissingPhotoPopup.swift
//  Depo
//
//  Created by Ozan Salman on 18.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

typealias PhotoPrintMissingPhotoPopupButtonHandler = (_: PhotoPrintMissingPhotoPopup) -> Void

final class PhotoPrintMissingPhotoPopup: BasePopUpController {
    
    @IBOutlet private weak var exitImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelUnborder.image
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.image = Image.iconPickNoPhotos.image
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 20)
            newValue.textColor = AppColor.forgetPassTimer.color
            newValue.text = localized(.printMissingPhotoPopupTitle)
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.printMissingPhotoPopupSubtitle)
            newValue.numberOfLines = 3
        }
    }
    
    @IBOutlet weak var nextButton: UIButton! {
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
    
    @IBOutlet private weak var selectButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.printSelectPhotoButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(AppColor.darkBlueColor.color, for: .normal)
            newValue.backgroundColor = .white
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }

    private var selectedPhotos = [SearchItemResponse]()
    private var selectedPhotoCount: Int = 0
    private var unSelectedPhotoCount: Int = 0
    private let router = RouterVC()
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
        
        titleLabel.text = String(format: localized(.printMissingPhotoPopupTitle), selectedPhotoCount)
        descriptionLabel.text = String(format: localized(.printMissingPhotoPopupSubtitle), unSelectedPhotoCount, unSelectedPhotoCount)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: {
            let vc = self.router.photoPrintViewController(selectedPhotos: self.selectedPhotos)
            self.router.pushViewController(viewController: vc)
        })
    }
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
    private func photoCount(selectedPhotoCount: Int, selectedPhotos: [SearchItemResponse]) {
        let selectablePhotoCount: Int = NumericConstants.photoPrintSelectablePhoto
        self.selectedPhotoCount = selectedPhotoCount
        self.unSelectedPhotoCount = selectablePhotoCount - selectedPhotoCount
        self.selectedPhotos = selectedPhotos
    }
    
}

// MARK: - Init
extension PhotoPrintMissingPhotoPopup {
    static func with(selectedPhotoCount: Int, selectedPhotos: [SearchItemResponse]) -> PhotoPrintMissingPhotoPopup {
        let vc = controllerWith(selectedPhotoCount: selectedPhotoCount, selectedPhotos: selectedPhotos)
        return vc
    }
    
    private static func controllerWith(selectedPhotoCount: Int, selectedPhotos: [SearchItemResponse]) -> PhotoPrintMissingPhotoPopup {
        let vc = PhotoPrintMissingPhotoPopup(nibName: "PhotoPrintMissingPhotoPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.photoCount(selectedPhotoCount: selectedPhotoCount, selectedPhotos: selectedPhotos)
        return vc
    }
}
