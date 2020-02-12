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
    case LargeFullOfQuotaPopUpTypeBetween80And99(_ percentage: Float)
    case LargeFullOfQuotaPopUpType100
}

//MARK: - LargeFullOfQuotaPopUpDelegate
protocol LargeFullOfQuotaPopUpDelegate: class {
    func onOpenExpandTap()
    func onDeleteFilesTap()
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
    
    @IBOutlet private weak var checkBoxLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.whiteColor
            newValue.text = TextConstants.instaPickDontShowThisAgain
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 16)
        }
    }
    @IBOutlet private weak var customCheckBox: CustomCheckBox! {
        willSet {
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = ColorConstants.whiteColor.cgColor
            newValue.setImage(UIImage(named: "applyIcon"), for: .selected)
            
        }
    }
    
    @IBOutlet private weak var expandButton: BlueButtonWithWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.lifeboxLargePopUpExpandButtonTitle, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "CloseCardIconWhite"), for: .normal)
        }
    }
    
    @IBOutlet private weak var deleteFilesButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.lifeboxLargePopUpDeleteFilesButtonTitle, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
            newValue.setTitleColor(ColorConstants.marineTwo, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = containerView
        
        titleLabel.text = LargeFullOfQuotaPopUp.textForTitle(type: viewType)
        setupBackgroundImageView()
        setupDoNotShowView()
    }
    
    //MARK: Actions
    @IBAction func onDeleteFilesButton() {
        close(isFinalStep: false) { [weak self] in
            self?.delegate?.onDeleteFilesTap()
            
            guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
                return
            }
            tabBarVC.showPhotoScreen()
        }
    }
    
    @IBAction func onCloseButton() {
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
    @IBOutlet private weak var doNotShowStackView: UIStackView!
    
    @IBAction private func onCustomCheckBoxTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        let storageVars: StorageVars = factory.resolve()
        storageVars.largeFullOfQuotaPopUpCheckBox = sender.isSelected
    }
    
    private func setupBackgroundImageView() {
        #if LIFEDRIVE
        //For Billo(Lifedrive) background image should be clear
        #else
        backgroundImageView.image = UIImage(named: "FullOfQuotaImage")
        #endif
    }
    private func setupDoNotShowView() {
        switch viewType {
        case .LargeFullOfQuotaPopUpTypeBetween80And99(_):
            doNotShowStackView.isHidden = true
        case .LargeFullOfQuotaPopUpType100:
            doNotShowStackView.isHidden = false
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
        case .LargeFullOfQuotaPopUpTypeBetween80And99(let usagePercentage):
            let percentage = (usagePercentage * 100).rounded(.toNearestOrAwayFromZero)
            return String(format: TextConstants.LifeboxLargePopUpTitleBetween80And99, percentage)
        case .LargeFullOfQuotaPopUpType100:
            return TextConstants.lifeboxLargePopUpTitle100
            
        }
    }
}
