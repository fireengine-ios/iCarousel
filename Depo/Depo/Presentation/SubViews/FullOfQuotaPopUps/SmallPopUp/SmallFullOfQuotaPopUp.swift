//
//  SmallFullOfQuotaPopUp.swift
//  PopUp
//
//  Created by Bondar Yaroslav on 12/12/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class SmallFullOfQuotaPopUp: BasePopUpController {
            
    //MARK: IBOutlet
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 10
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var buttonsView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkBlueColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var checkBoxlabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var firstImageView: UIImageView! {
        willSet {
            newValue.image = PopUpImage.error.image
        }
    }
    
    @IBOutlet private weak var customCheckBox: CustomCheckBox!
    
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
            
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    //MARK: Utility methods
    private func setupView() {
        setupButtonState()
        
        contentView = containerView
        
        titleLabel.text = TextConstants.fullQuotaSmallPopUpTitle
        messageLabel.text = TextConstants.fullQuotaSmallPopUpSubTitle
        checkBoxlabel.text = TextConstants.fullQuotaSmallPopUpCheckBoxText
    }
    
    private func setupButtonState() {
        setup(firstButton, title: TextConstants.fullQuotaSmallPopUpFistButtonTitle)
        setup(secondButton, title: TextConstants.fullQuotaSmallPopUpSecondButtonTitle)
    }
    
    private func setup(_ button: UIButton, title: String) {
        button.isHidden = false
        button.isExclusiveTouch = true
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(ColorConstants.blueColor, for: .normal)
        button.setTitleColor(ColorConstants.blueColor.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.blueColor, for: .highlighted)
        button.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        button.adjustsFontSizeToFitWidth()
    }
    
    private func saveCheckBoxState() {
        guard customCheckBox.isChecked else {
            return
        }
        
        let storageVars: StorageVars = factory.resolve()
        storageVars.smallFullOfQuotaPopUpCheckBox = true
    }
    
    //MARK: IBAction
    @IBAction func actionFirstButton(_ sender: UIButton) {
        saveCheckBoxState()
        close()
    }
    
    @IBAction func actionSecondButton(_ sender: UIButton) {
        saveCheckBoxState()
        close(isFinalStep: false) {
            let router = RouterVC()
            let viewController = router.packages
            router.pushViewController(viewController: viewController)
        }
    }
}

//MARK: - Init
extension SmallFullOfQuotaPopUp {
    static func popUp() -> SmallFullOfQuotaPopUp? {
        let storageVars: StorageVars = factory.resolve()
        
        let isSkiped = storageVars.smallFullOfQuotaPopUpCheckBox
        guard !isSkiped else {
            return nil
        }
        
        let vc = SmallFullOfQuotaPopUp(nibName: "SmallFullOfQuotaPopUp", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        return vc
    }
}
