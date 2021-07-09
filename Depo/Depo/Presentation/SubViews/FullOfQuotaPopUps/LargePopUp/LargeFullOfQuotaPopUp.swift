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
    case LargeFullOfQuotaPopUpType100(_ premium: Bool)
}

//MARK: - LargeFullOfQuotaPopUpDelegate
protocol LargeFullOfQuotaPopUpDelegate: AnyObject {
    func onOpenExpandTap()
    func onDeleteFilesTap()
}

final class LargeFullOfQuotaPopUp: BasePopUpController {
    
    //MARK: Properties
    weak var delegate: LargeFullOfQuotaPopUpDelegate?
    
    var viewType: LargeFullOfQuotaPopUpType = .LargeFullOfQuotaPopUpType100(false)
    
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private var doNotShowAgain: Bool = false
    
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
            newValue.accessibilityLabel = TextConstants.accessibilityClose
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
    
    @IBOutlet private weak var skipButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.lifeboxLargePopUpSkipButtonTitle, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
            newValue.setTitleColor(ColorConstants.grayTabBarButtonsColor, for: .normal)
            newValue.adjustsFontSizeToFitWidth()
        }
    }
     
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView = containerView
        
        titleLabel.text = LargeFullOfQuotaPopUp.textForTitle(type: viewType)
        subTitleLabel.text = LargeFullOfQuotaPopUp.textForSubtitle(type: viewType)
        setupBackgroundImageView()
        setupViewAsType()
    }
    
    //MARK: Actions
    @IBAction func onSkipButton() {
        close()
        analyticsHandler(eventLabel: .overQuota(.skip))
    }
    
    @IBAction func onDeleteFilesButton() {
        close(isFinalStep: false) { [weak self] in
            self?.delegate?.onDeleteFilesTap()
            
            let router = RouterVC()
            router.tabBarController?.showPhotoScreen()
        }
        analyticsHandler(eventLabel: .overQuota(.deleteFiles(doNotShowAgain)))
    }
    
    @IBAction func onCloseButton() {
        close()
        analyticsHandler(eventLabel: .overQuota(.cancel(doNotShowAgain)))
    }
    
    @IBAction func onExpandButton() {
        close(isFinalStep: false) { [weak self] in
            self?.delegate?.onOpenExpandTap()

            let router = RouterVC()
            let viewController = router.packages
            viewController.needToShowTabBar = false
            router.pushViewController(viewController: viewController)
        }
        analyticsHandler(eventLabel: .overQuota(.expandMyStorage(doNotShowAgain)))
    }
    
    @IBOutlet private weak var doNotShowStackView: AccessibleCheckBoxView!
    
    @IBAction private func onCustomCheckBoxTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        doNotShowAgain = sender.isSelected
        let storageVars: StorageVars = factory.resolve()
        storageVars.largeFullOfQuotaPopUpCheckBox = doNotShowAgain
    }
    
    private func setupBackgroundImageView() {
        #if LIFEDRIVE
        //For Billo(Lifedrive) background image should be clear
        #else
        backgroundImageView.image = UIImage(named: "FullOfQuotaImage")
        #endif
    }
    
    private func setupViewAsType() {
        switch viewType {
        case .LargeFullOfQuotaPopUpTypeBetween80And99:
            doNotShowStackView.isHidden = true
            closeButton.isHidden = true
            deleteFilesButton.isHidden = true
            skipButton.isHidden = false
        case .LargeFullOfQuotaPopUpType100:
            doNotShowStackView.isHidden = false
            closeButton.isHidden = false
            deleteFilesButton.isHidden = false
            skipButton.isHidden = true
        }
    }
    
    private func analyticsHandler(eventLabel: GAEventLabel) {
        let eventAction: GAEventAction
           
        switch viewType {
        case .LargeFullOfQuotaPopUpTypeBetween80And99:
            eventAction = .quotaAlmostFullPopup
        case .LargeFullOfQuotaPopUpType100(let premium):
            eventAction = premium ? .overQuotaPremiumPopup: .overQuotaFreemiumPopup
        }
        
        self.analyticsService.trackCustomGAEvent(eventCategory: .popUp, eventActions: eventAction, eventLabel: eventLabel)
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
            return String(format: TextConstants.lifeboxLargePopUpTitleBetween80And99, percentage)
        case .LargeFullOfQuotaPopUpType100:
            return TextConstants.lifeboxLargePopUpTitle100
            
        }
    }
    
    private static func textForSubtitle(type: LargeFullOfQuotaPopUpType) -> String {
        switch type {
        case .LargeFullOfQuotaPopUpTypeBetween80And99(_):
            return TextConstants.lifeboxLargePopUpSubTitleBeetween80And99
        case .LargeFullOfQuotaPopUpType100(let premium):
            return premium ? TextConstants.lifeboxLargePopUpSubTitle100Premium:
                             TextConstants.lifeboxLargePopUpSubTitle100Freemium
        }
    }
}
