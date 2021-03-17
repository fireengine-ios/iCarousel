//
//  AgreementsSegmentedControl.swift
//  Depo
//
//  Created by Vyacheslav Bakinskiy on 10.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol AgreementsSegmentedControlDelegate: class {
    func segmentedControlButton(didChangeIndexTo index: Int)
}

final class AgreementsSegmentedControl: UIView, NibInit {
    
    //MARK: - Public properties
    
    weak var delegate: AgreementsSegmentedControlDelegate?
    
    //MARK: - Private properties
    
    private var buttonTitles = [TextConstants.termsOfUseAgreement, TextConstants.privacyPolicyAgreement]
    private var buttons = [UIButton]()
    private var selectorView: UIView!
    private var dividerView: UIView!
    
    //MARK: - @IBOutlets
    
    @IBOutlet private weak var stackView: UIStackView!
    
    //MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateView()
    }
    
    //MARK: - Setup
    
    private func createButton() {
        buttons.removeAll()
        
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            setButtonLikeNotPressed(button)
            button.addTarget(self, action: #selector(AgreementsSegmentedControl.buttonAction(sender:)), for: .touchUpInside)
            buttons.append(button)
        }
    }
    
    private func setButtonLikePressed(_ button: UIButton?) {
        button?.titleLabel?.font =  UIFont.GTAmericaStandardMediumFont(size: 14)
        button?.setTitleColor(ColorConstants.confirmationPopupTitle, for: .normal)
    }
    
    private func setButtonLikeNotPressed(_ button: UIButton?) {
        button?.titleLabel?.font =  UIFont.GTAmericaStandardRegularFont(size: 14)
        button?.setTitleColor(ColorConstants.multifileCellSubtitleText, for: .normal)
    }
    
    private func configStackView() {
        buttons.forEach(stackView.addArrangedSubview)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
    }
    
    private func configSelectorView() {
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        let selectorHeight: CGFloat = 3
        selectorView = UIView(frame: CGRect(x: 0,
                                            y: self.frame.height,
                                            width: selectorWidth,
                                            height: selectorHeight))
        selectorView.backgroundColor = ColorConstants.confirmationPopupTitle
        
        dividerView = UIView(frame: CGRect(x: 0,
                                           y: self.frame.height + selectorHeight,
                                           width: self.frame.width,
                                           height: 0.7))
        dividerView.backgroundColor = ColorConstants.separator
        
        addSubview(selectorView)
        addSubview(dividerView)
    }
    
    private func updateView() {
        createButton()
        configStackView()
        configSelectorView()
        setButtonLikePressed(buttons.first)
    }
    
    //MARK: - Action
    
    @objc func buttonAction(sender: UIButton) {
        for (buttonIndex, button) in buttons.enumerated() {
            setButtonLikeNotPressed(button)
            
            if button == sender {
                let selectorPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
                delegate?.segmentedControlButton(didChangeIndexTo: buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selectorView.frame.origin.x = selectorPosition
                }
                setButtonLikePressed(button)
            }
        }
    }
}
