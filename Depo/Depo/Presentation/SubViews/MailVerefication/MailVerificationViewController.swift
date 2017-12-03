//
//  MailVereficationViewController.swift
//  Depo_LifeTech
//
//  Created by Aleksandr on 11/30/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol MailVerificationViewControllerDelegate {
    func mailVerified()
    func mailVerificationFailed()
}

class MailVerificationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    weak var actionDelegate: MailVerificationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 16)
        titleLabel.textColor = UIColor.darkGray
        titleLabel.text = TextConstants.mailVereficationMainTitleText
        
        sendButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        sendButton.titleLabel?.textColor = UIColor.lrTiffanyBlue
        sendButton.titleLabel?.text = TextConstants.registrationNextButtonText
    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        debugPrint("send action")
        self.actionDelegate?.mailVerified()
    }
    
}
