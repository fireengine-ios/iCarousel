//
//  CreateStoryPopUp.swift
//  Depo
//
//  Created by Raman Harhun on 7/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum DesignText {
    case full(attributes: [NSAttributedStringKey : Any])
    case partly(parts: [String : [NSAttributedStringKey : Any]])
}

final class CreateStoryPopUp: UIViewController, NibInit {
    
    //MARK: IBOutlets
    @IBOutlet private weak var blurView: UIVisualEffectView! {
        willSet {
            newValue.alpha = 0.9
            newValue.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
    }

    @IBOutlet private weak var popUpView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet private weak var actionButton: InsetsButton! {
        willSet {
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.setTitleColor(UIColor.lrTealish, for: .normal)

            newValue.layer.cornerRadius = 22
            
            newValue.layer.borderWidth = 1
            newValue.layer.borderColor = UIColor.lrTealish.cgColor
            
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    //MARK: Vars
    private var popUpImage: UIImage?
    private var popUpTitle: String = ""
    private var titleDesign: DesignText = .full(attributes: [:])
    private var message: String = ""
    private var messageDesign: DesignText = .full(attributes: [:])
    private var buttonTitle: String = ""
    private var buttonAction: VoidHandler?
    
    static func with(image: UIImage?,
                     title: String,
                     titleDesign: DesignText,
                     message: String,
                     messageDesign: DesignText,
                     buttonTitle: String,
                     buttonAction: @escaping VoidHandler) -> CreateStoryPopUp
    {
        let controller = CreateStoryPopUp.initFromNib()
        
        controller.popUpImage = image
        controller.popUpTitle = title
        controller.titleDesign = titleDesign
        controller.message = message
        controller.messageDesign = messageDesign
        controller.buttonTitle = buttonTitle
        controller.buttonAction = buttonAction

        return controller
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
        }
    }

    //MARK: Utility methods
    private func setup() {
        view.alpha = 0
        
        imageView.image = popUpImage
        
        titleLabel.attributedText = configureDesign(for: popUpTitle, with: titleDesign)
        messageLabel.attributedText = configureDesign(for: message, with: messageDesign)
        
        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func configureDesign(for text: String, with params: DesignText) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: text)
        switch params {
        case .full(attributes: let attributes):
            if let range = NSRange(text) {
                attributedString.addAttributes(attributes, range: range)
            }
            
        case .partly(parts: let parts):
            let sortedParts = parts.sorted(by: { left, right in
                left.key.count > right.key.count
            })
            for part in sortedParts.enumerated() {
                if let range = text.range(of: part.element.key) {
                    let nsRange = NSRange(location: range.lowerBound.encodedOffset,
                                          length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
                    attributedString.addAttributes(part.element.value, range: nsRange)
                }
            }
        }
        
        return attributedString
    }
    
    //MARK: Action
    @IBAction func onButtonTap(_ sender: Any) {
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
        }, completion: { isSuccess in
            self.dismiss(animated: false) {
                self.buttonAction?()
            }
        })
    }
    
}
