//
//  ContactUsViewController.swift
//  Depo
//
//  Created by Vyacheslav Bakinskiy on 18.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class ContactUsViewController: BaseViewController, NibInit {
    
    //MARK: - @IBOutlets
    
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var subjectContainerView: UIView!
    @IBOutlet weak private var subjectLabel: UILabel!
    @IBOutlet weak private var subjectButton: UIButton!
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var sendButton: UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSubjectButton()
        setTextField()
        setSendButton()
    }
    
    //MARK: - Setup
    
    private func setSubjectButton() {
        subjectContainerView.layer.cornerRadius = 5
        subjectContainerView.layer.borderWidth = 1
        subjectContainerView.layer.borderColor = ColorConstants.a2FABorder.cgColor
    }
    
    private func setTextField() {
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = ColorConstants.a2FABorder.cgColor
    }
    
    private func setSendButton() {
//        sendButton.isEnabled = false
        
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        
        sendButton.backgroundColor = ColorConstants.confirmationPopupButton
        sendButton.layer.cornerRadius = 5
    }
    

    
    //MARK: - @IBActions
    
    @IBAction func subjectButonPressed(_ sender: Any) {
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
    }
}
