//
//  MessageAndButtonPopup.swift
//  Depo
//
//  Created by Burak Donat on 1.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol MessageAndButtonPopupDelegate: AnyObject {
    func onActionButton()
}

final class MessageAndButtonPopup: BasePopUpController, NibInit {
    
    weak var delegate: MessageAndButtonPopupDelegate?
    var message: String?
    var buttonTitle: String?
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 20)
            newValue.textColor = AppColor.blackColor.color
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var actionButton: RoundedButton! {
        willSet {
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(UIColor.lrTealish, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.layer.cornerRadius = 25
        }
    }
    
    @IBOutlet private weak var popupView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.popUpBackground.color
        setup()
    }
    
    @IBAction func onActionButton(_ sender: Any) {
        delegate?.onActionButton()
    }
    
    func setup() {
        messageLabel.text = message
        actionButton.setTitle(buttonTitle, for: .normal)
    }
}
