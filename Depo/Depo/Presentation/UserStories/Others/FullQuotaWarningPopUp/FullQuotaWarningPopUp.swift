//
//  FullQuotaWarningPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 2/7/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum FullQuotaWarningPopUpType {
    case standard
    case contact
    
    var title: String {
        switch self {
        case .standard:
            return TextConstants.fullQuotaWarningPopUpTitle
        case .contact:
            return TextConstants.contactSyncDepoErrorTitle
        }
    }
    
    var description: String {
        switch self {
        case .standard:
            return TextConstants.fullQuotaWarningPopUpDescription
        case .contact:
            return TextConstants.contactSyncDepoErrorMessage
        }
    }
    
    var expandQuotaButton: String {
        switch self {
        case .standard:
            return TextConstants.expandMyStorage
        case .contact:
            return TextConstants.contactSyncDepoErrorUpButtonText
        }
    }
    
    var deleteFilesButton: String {
        switch self {
        case .standard:
            return TextConstants.deleteFiles
        case .contact:
            return TextConstants.contactSyncDepoErrorDownButtonText
        }
    }
    
    var eventAction: GAEventAction {
        switch self {
        case .standard:
            return .quotaLimitFullPopup
        case .contact:
            return .quotaLimitFullContactRestore
        }
    }

}

final class FullQuotaWarningPopUp: BasePopUpController {
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private var popUpType: FullQuotaWarningPopUpType = .standard

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
            newValue.text = popUpType.title
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
            newValue.textColor = UIColor.lrPeach
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.text = popUpType.description
            newValue.textColor = ColorConstants.darkGrayTransperentColor
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var expandQuotaButton: RoundedInsetsButton!  {
        willSet {
            newValue.setTitle(popUpType.expandQuotaButton, for: .normal)
            newValue.setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.insets = UIEdgeInsets(topBottom: 5, rightLeft: 30)
        }
    }
    
    @IBOutlet private weak var deleteFilesButton: UIButton! {
        willSet {
            newValue.setTitle(popUpType.deleteFilesButton, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
            newValue.setTitleColor(ColorConstants.darkBlueColor, for: .normal)
        }
    }
    
    //MARK: Init
    init(_ popUpType: FullQuotaWarningPopUpType = .standard) {
        super.init(nibName: nil, bundle: nil)
        self.popUpType = popUpType
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
        analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: popUpType.eventAction, eventLabel:  .overQuota(.cancel()))
    }
    
    @IBAction private func onExpandQuotaTap(_ sender: UIButton) {
        close {
            let router = RouterVC()
            router.pushViewController(viewController: router.packages)
        }
        analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: popUpType.eventAction, eventLabel:  .overQuota(.expandMyStorage()))
    }
    
    @IBAction private func onDeleteFilesTap(_ sender: UIButton) {
        close {
            let router = RouterVC()
            
            guard let presentingViewController = router.navigationController?.presentingViewController else {
                router.tabBarController?.showPhotoScreen()
                return
            }
            
            presentingViewController.dismiss(animated: true) {
                router.tabBarController?.showPhotoScreen()
            }
        }
        analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: popUpType.eventAction, eventLabel:  .overQuota(.deleteFiles()))
    }
}
