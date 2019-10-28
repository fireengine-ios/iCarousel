//
//  LargeFullOfQuotaPopUp.swift
//  Depo
//
//  Created by Oleg on 11.04.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

//MARK: - LargeFullOfQuotaPopUpType
enum LargeFullOfQuotaPopUpType{
    case LargeFullOfQuotaPopUpType80
    case LargeFullOfQuotaPopUpType90
    case LargeFullOfQuotaPopUpType100
}

//MARK: - LargeFullOfQuotaPopUpDelegate
protocol LargeFullOfQuotaPopUpDelegate: class {
    func onOpenExpandTap()
}

final class LargeFullOfQuotaPopUp: BasePopUpController {
    
    //MARK: Properties
    weak var delegate: LargeFullOfQuotaPopUpDelegate?
    
    var viewType: LargeFullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType100
    
    //MARK: IBOutlets
    @IBOutlet weak var gradientView: GradientOrangeView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 10
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.whiteColor
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 28)
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.whiteColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.text = TextConstants.lifeboxLargePopUpSubTitle
        }
    }
    
    @IBOutlet private weak var expandButton: BlueButtonWithWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.lifeboxLargePopUpExpandButtonTitle, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var skipButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.lifeboxLargePopUpSkipButtonTitle, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
            newValue.setTitleColor(ColorConstants.grayTabBarButtonsColor, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = containerView
        
        titleLabel.text = LargeFullOfQuotaPopUp.textForTitle(type: viewType)
    }
    
    //MARK: Actions
    @IBAction func onSkipButton() {
        close()
    }
    
    @IBAction func onExpandButton() {
        close(isFinalStep: false) { [weak self] in
            self?.delegate?.onOpenExpandTap()

            let router = RouterVC()
            let viewController = router.packages
            viewController.needToShowTabBar = false
            router.pushViewController(viewController: viewController)
        }
    }
}

//MARK: - Init
extension LargeFullOfQuotaPopUp {
    static func popUp(type: LargeFullOfQuotaPopUpType) -> LargeFullOfQuotaPopUp {
        let controller = LargeFullOfQuotaPopUp(nibName: "LargeFullOfQuotaPopUp", bundle: nil)
        
        controller.viewType = type

        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        
        return controller
    }
    
    private static func textForTitle(type: LargeFullOfQuotaPopUpType) -> String {
        switch type {
        case .LargeFullOfQuotaPopUpType80:
            return TextConstants.lifeboxLargePopUpTitle80
            
        case .LargeFullOfQuotaPopUpType90:
            return TextConstants.lifeboxLargePopUpTitle90
            
        case .LargeFullOfQuotaPopUpType100:
            return TextConstants.lifeboxLargePopUpTitle100
            
        }
    }
}
