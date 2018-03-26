//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class TermsAndServicesViewController: UIViewController, TermsAndServicesViewInput, UITextViewDelegate {

    var output: TermsAndServicesViewOutput!

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var acceptButton: BlueButtonWithWhiteText!
    
    @IBOutlet weak var topContraintIOS10: NSLayoutConstraint!
    @IBOutlet weak var topContraintIOS11: NSLayoutConstraint!
    
    // MARK: Life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hidenNavigationBarStyle()        
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.termsAndUsesTitile)
        }

        if #available(iOS 11.0, *) {
            topContraintIOS10.isActive = false
        } else {
            topContraintIOS11.isActive = false
        }
        
        configureUI()
        
        output.viewIsReady()
    }

    private func configureUI() {
        welcomeLabel.text = TextConstants.termsAndUseWelcomeText
        welcomeLabel.font = UIFont.TurkcellSaturaDemFont(size: 25)
        welcomeLabel.textColor = ColorConstants.darcBlueColor
        
        checkboxLabel.text = TextConstants.termsAndUseCheckboxText
        checkboxLabel.font = UIFont.TurkcellSaturaRegFont(size: 12)
        checkboxLabel.textColor = ColorConstants.darkText
        
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
        
        textView.textContainerInset.right = 10
        textView.text = ""
        textView.dataDetectorTypes = [.phoneNumber, .link]
        textView.indicatorStyle = .white
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    // MARK: Buttons action
    
    @IBAction func onStartUsing(_ sender: Any) {
        output.startUsing()
    }
    
    @IBAction func onCheckbox(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        button.isSelected = !button.isSelected
        
        output.confirmAgreements(button.isSelected)
    }

    // MARK: TermsAndServicesViewInput
    func setupInitialState() {
        
    }
    
    func showLoadedTermsAndUses(eula: String) {
        guard let htmlData = eula.data(using: String.Encoding.utf8) else {
            return
        }
        
        do {
            let string = try NSMutableAttributedString(data: htmlData,
                                                       options: [.documentType: NSAttributedString.DocumentType.html,
                                                                 .characterEncoding: String.Encoding.utf8.rawValue],
                                                       documentAttributes: nil)
            string.addAttributes([.foregroundColor: ColorConstants.whiteColor], range: NSRange(location: 0, length: string.length))
            textView.attributedText = string
        } catch {
            print("error: ", error)
        }
    }
    
    func noConfirmAgreements(errorString: String) {
        UIApplication.showErrorAlert(message: errorString)
    }
    
    func failLoadTermsAndUses(errorString: String) {
        //TO-DO show error
    }
    
    func popNavigationVC() {
        navigationController?.popViewController(animated: true)
    }
}
