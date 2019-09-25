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
            newValue.textColor = UIColor.lrTealish
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.text = TextConstants.userProfileSecretQuestion
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var lineView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.lightText.withAlphaComponent(0.5)
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
            self.descriptionLabel.textColor = UIColor.black
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
