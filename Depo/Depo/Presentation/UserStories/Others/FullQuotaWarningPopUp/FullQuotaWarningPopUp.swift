//
//  FullQuotaWarningPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 2/7/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class FullQuotaWarningPopUp: BasePopUpController {

    //MARK: IBOutlets
    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            let image = UIImage(named: "grayCloseButton")
            newValue.setImage(image, for: .normal)
            newValue.contentEdgeInsets = UIEdgeInsets(topBottom: 8, rightLeft: 8)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!{
        willSet {
            newValue.image = UIImage(named: "CardIconPeachLamp")
        }
    }
    
    @IBOutlet private weak var titleLable: UILabel! {
        willSet {
            newValue.text = TextConstants.fullQuotaWarningPopUpTitle
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
            newValue.textColor = UIColor.lrPeach
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fullQuotaWarningPopUpDescription
            newValue.textColor = ColorConstants.darkGrayTransperentColor
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var expandQuotaButton: RoundedInsetsButton!  {
        willSet {
            newValue.setTitle(TextConstants.expandMyStorage, for: .normal)
            newValue.setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.insets = UIEdgeInsets(topBottom: 5, rightLeft: 30)
        }
    }
    
    @IBOutlet private weak var deleteFilesButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.deleteFiles, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
            newValue.setTitleColor(ColorConstants.darkBlueColor, for: .normal)
        }
    }
    
    //MARK: Init
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView = popUpView
    }
        
    //MARK: Actions
    @IBAction private func onCloseTap(_ sender: UIButton) {
        close()
    }
    
    @IBAction private func onExpandQuotaTap(_ sender: UIButton) {
        close {
            let router = RouterVC()
            router.pushViewController(viewController: router.packages)
        }
    }
    
    @IBAction private func onDeleteFilesTap(_ sender: UIButton) {
        close {
            let router = RouterVC()
            router.tabBarController?.showPhotoScreen()
        }
    }
}
