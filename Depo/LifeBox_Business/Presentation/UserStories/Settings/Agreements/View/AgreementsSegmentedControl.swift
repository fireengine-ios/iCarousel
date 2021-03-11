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

final class AgreementsSegmentedControl: UIView {
    
    //MARK: - Public properties
    
    weak var delegate: AgreementsSegmentedControlDelegate?
    
    var textColor: UIColor = ColorConstants.multifileCellSubtitleText
    var selectorViewColor: UIColor = ColorConstants.confirmationPopupTitle
    var selectorTextColor: UIColor = ColorConstants.confirmationPopupTitle
    var dividerViewColor: UIColor = ColorConstants.separator
    
    //MARK: - Private properties
    
    private var buttonTitles: [String]!
    private var buttons: [UIButton]!
    private var selectorView: UIView!
    private var dividerView: UIView!
    
    //MARK: - Init
    
    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
    }
    
    //MARK: - Setup
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView()
    }
    
    func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        updateView()
    }
    
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach ({ $0.removeFromSuperview() })
        
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
        button?.setTitleColor(selectorTextColor, for: .normal)
    }
    
    private func setButtonLikeNotPressed(_ button: UIButton?) {
        button?.titleLabel?.font =  UIFont.GTAmericaStandardRegularFont(size: 14)
        button?.setTitleColor(textColor, for: .normal)
    }
    
    private func configStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func configSelectorView() {
        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: selectorWidth, height: 3))
        selectorView.backgroundColor = selectorViewColor
        
        dividerView = UIView(frame: CGRect(x: 0, y: self.frame.height + 3, width: self.frame.width, height: 0.7))
        dividerView.backgroundColor = dividerViewColor
        
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
