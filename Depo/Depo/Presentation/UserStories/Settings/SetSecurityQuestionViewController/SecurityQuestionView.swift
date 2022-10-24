//
//  SecurityQuestionView.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol SecurityQuestionViewDelegate {
    func selectSecurityQuestionTapped()
}

final class SecurityQuestionView: UIView, NibInit {

    var showsArrowButton: Bool = true {
        didSet {
            arrowButton.isHidden = !showsArrowButton
        }
    }

    var delegate: SecurityQuestionViewDelegate?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setDescriptionLabelTitle()
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.light, size: 14.0)
            newValue.text = "  " + TextConstants.userProfileSecretQuestion + "  "
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14.0)
            newValue.textColor = AppColor.label.color
            newValue.backgroundColor = AppColor.primaryBackground.color
            newValue.isOpaque = true
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.layer.borderColor = AppColor.darkTextAndLightGray.cgColor
            newValue.layer.borderWidth = 1.0
            newValue.layer.cornerRadius = 8.0
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var arrowButton: UIButton!
    
    private func setup() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        self.addGestureRecognizer(gesture)
    }
    
    func setQuestion(question: String) {
        DispatchQueue.toMain {
            self.descriptionLabel.text = question
            self.descriptionLabel.textColor = AppColor.blackColor.color
        }
    }
    
    private func setDescriptionLabelTitle() {
        descriptionLabel.text = TextConstants.userProfileSecretQuestionLabelPlaceHolder
    }
    
    @objc func viewWasTapped() {
         delegate?.selectSecurityQuestionTapped()
    }
    
    @IBAction private func arrowButtonTapped(_ sender: Any) {
        delegate?.selectSecurityQuestionTapped()
    }
}
