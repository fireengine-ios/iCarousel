//
//  PhotoPrintInfoPopup.swift
//  Depo
//
//  Created by Ozan Salman on 17.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

typealias PhotoPrintInfoPopupButtonHandler = (_: PhotoPrintInfoPopup) -> Void

final class PhotoPrintInfoPopup: BasePopUpController {
    
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
            newValue.text = localized(.printInfoPopUpTitle)
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.printInfoPopUpSubtitle)
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet private weak var selectButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.printSelectPhotoButton), for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = AppColor.darkBlueColor.color
            newValue.layer.cornerRadius = newValue.frame.size.height * 0.5
            newValue.clipsToBounds = true
            newValue.layer.borderWidth = 1.0
            newValue.layer.borderColor = AppColor.darkBlueColor.cgColor
        }
    }
    
    @IBOutlet weak var checkBoxButton: UIButton! {
        willSet {
            newValue.setImage(Image.iconSelectEmpty.image, for: .normal)
            newValue.setImage(Image.iconSelectFills.image, for: .selected)
        }
    }
    
    @IBOutlet weak var checkBoxLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 0
            newValue.text = localized(.printInfoPopupCheckBox)
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
        }
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exitImageView.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        exitImageView.addGestureRecognizer(tapImage)
    }
    
    @IBAction func checkBoxButtonTapped(_ sender: Any) {
        (sender as! UIButton).isSelected = !(sender as! UIButton).isSelected
        UserDefaults.standard.set((sender as! UIButton).isSelected, forKey: "photoPrintNotShowingPopup")
    }
    
    @IBAction func selectPhotoTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
    
}

// MARK: - Init
extension PhotoPrintInfoPopup {
    static func with() -> PhotoPrintInfoPopup {
        let vc = controllerWith()
        return vc
    }
    
    private static func controllerWith() -> PhotoPrintInfoPopup {
        let vc = PhotoPrintInfoPopup(nibName: "PhotoPrintInfoPopup", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        return vc
    }
}
