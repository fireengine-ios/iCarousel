//
//  TermsAndServicesTermsAndServicesViewController.swift
//  Depo
//
//  Created by AlexanderP on 09/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import WebKit

class TermsAndServicesViewController: ViewController {

    var output: TermsAndServicesViewOutput!

    @IBOutlet private weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var contentView: UITextView! {
        willSet {
            newValue.text = ""
            newValue.backgroundColor = ColorConstants.bottomViewGrayColor
            newValue.layer.borderColor = ColorConstants.lightGrayColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
            ]
            newValue.dataDetectorTypes = [.link, .phoneNumber]
            newValue.isEditable = false
            
            /// to remove insets
            /// https://stackoverflow.com/a/42333832/5893286
            newValue.textContainer.lineFragmentPadding = 0
            let defaultInset: CGFloat = 14
            newValue.textContainerInset = UIEdgeInsets(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)
            newValue.delegate = self
        }
    }
    
    @IBOutlet private weak var acceptButton: BlueButtonWithWhiteText!
    @IBOutlet private weak var checkboxesStack: UIStackView! {
        willSet {
            newValue.spacing = 10 //Design
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.bounces = false
        }
    }
    
    @IBOutlet private weak var topContraintIOS10: NSLayoutConstraint!
    @IBOutlet private weak var topContraintIOS11: NSLayoutConstraint!

    @IBOutlet private weak var contenViewHeightConstraint: NSLayoutConstraint!
    
    private let generalTermsCheckboxView = TermsCheckboxTextView.initFromNib()
    private var etkTermsCheckboxView: TermsCheckboxTextView?
    private var globalDataPermissionTermsCheckboxView: TermsCheckboxTextView?
    
    //MARK: - Life cycle
    
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

        contenViewHeightConstraint.constant = Device.winSize.height * 0.5
        if #available(iOS 11.0, *) {
            topContraintIOS10.isActive = false
        } else {
            topContraintIOS11.isActive = false
        }
        
        configureUI()
        setupIntroductionTextView()
        output.viewIsReady()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hideSpinnerIncludeNavigationBar()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    //MARK: - Configuration and Input
    private func configureUI() {
        welcomeLabel.text = TextConstants.termsAndUseWelcomeText
        welcomeLabel.font = UIFont.TurkcellSaturaDemFont(size: 25)
        welcomeLabel.textColor = ColorConstants.darkBlueColor
       
        view.layoutIfNeeded()
        
        acceptButton.setTitle(TextConstants.termsAndUseStartUsingText, for: .normal)
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    func showEtk() {
        setupEtkText()
        view.layoutIfNeeded()
    }
    
    func showGlobalPermissions() {
        setupGlobalPermissionTextView()
        view.layoutIfNeeded()
    }
    
    private func setupIntroductionTextView() {
        checkboxesStack.addArrangedSubview(generalTermsCheckboxView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseIntroductionCheckbox,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let rangeLink = header.mutableString.range(of: TextConstants.privacyPolicyCondition)
        header.addAttributes([.link: TextConstants.NotLocalized.privacyPolicyConditions], range: rangeLink)
        
        generalTermsCheckboxView.setup(atributedTitleText: header, atributedText: nil, delegate: self)
    }
    
    private func setupEtkText() {
        let etkChecboxView = TermsCheckboxTextView.initFromNib()
        etkTermsCheckboxView = etkChecboxView
        checkboxesStack.addArrangedSubview(etkChecboxView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckboxHeader,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let descriptionText = NSMutableAttributedString(string: TextConstants.termsAndUseEtkCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: UIColor.lightGray])
        
        let rangeLink1 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkTurkcellAndGroupCompanies)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies], range: rangeLink1)
        
        let rangeLink2 = descriptionText.mutableString.range(of: TextConstants.termsAndUseEtkLinkCommercialEmailMessages)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages], range: rangeLink2)

        etkChecboxView.setup(atributedTitleText: header, atributedText: descriptionText, delegate: self)
    }

    func setupGlobalPermissionTextView() {
        let globalPermissionsView = TermsCheckboxTextView.initFromNib()
        globalDataPermissionTermsCheckboxView = globalPermissionsView
        checkboxesStack.addArrangedSubview(globalPermissionsView)
        
        let header = NSMutableAttributedString(string: TextConstants.termsOfUseGlobalPermHeader,
                                               attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 15),
                                                            .foregroundColor: ColorConstants.darkText])
        
        let descriptionText = NSMutableAttributedString(string: TextConstants.termsOfUseGlobalDataPermCheckbox,
                                                 attributes: [.font: UIFont.TurkcellSaturaRegFont(size: 12),
                                                              .foregroundColor: UIColor.lightGray])
        let rangeLink1 = descriptionText.mutableString.range(of: TextConstants.termsOfUseGlobalDataPermLinkSeeDetails)
        descriptionText.addAttributes([.link: TextConstants.NotLocalized.termsOfUseGlobalDataPermLink1], range: rangeLink1)
        
        globalPermissionsView.setup(atributedTitleText: header, atributedText: descriptionText, delegate: self)
    }
    
    // MARK: Buttons action
    
    @IBAction func onStartUsing(_ sender: Any) {
        output.startUsing()
    }
}

// MARK: - TermsAndServicesViewInput
extension TermsAndServicesViewController: TermsAndServicesViewInput {
    
    func setupInitialState() {
    }
    
    func showLoadedTermsAndUses(eula: String) {
        guard !eula.isEmpty else {
            return
        }
        DispatchQueue.global().async { [weak self] in
            let font = UIFont.TurkcellSaturaRegFont(size: 14)
            /// https://stackoverflow.com/a/27422343
            let customFontEulaString = "<style>body{font-family: '\(font.familyName)'; font-size:\(font.pointSize);}</style>" + eula
            guard let data = customFontEulaString.data(using: .utf8) else {
                assertionFailure()
                return
            }
            /// https://stackoverflow.com/q/50969015/5893286
            /// fixed black screen
            /// and error "AttributedString called within transaction"

            do {
                let attributedString = try NSAttributedString(data: data, options:
                    [.documentType: NSAttributedString.DocumentType.html,
                     .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                
                DispatchQueue.main.async {
                    self?.contentView.attributedText = attributedString
                }
            } catch {
                assertionFailure()
            }
        }
    }
    
    func hideBackButton() {
        navigationItem.setHidesBackButton(true, animated: false)
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

// MARK: - TermsCheckboxTextViewDelegate
extension TermsAndServicesViewController: TermsCheckboxTextViewDelegate {
    
    ///sender here is not a button but the whole view
    func checkBoxPressed(isSelected: Bool, sender: TermsCheckboxTextView) {
        
        if sender == generalTermsCheckboxView {
            output.confirmAgreements(isSelected)
        } else if let etkTermsCheckboxView = etkTermsCheckboxView,
            sender == etkTermsCheckboxView {
            output.confirmEtk(isSelected)
        } else if let globalDataPermissionTermsCheckboxView = globalDataPermissionTermsCheckboxView,
            sender == globalDataPermissionTermsCheckboxView {
            output.confirmGlobalPerm(isSelected)
        }
    }
    
    func tappedOnURL(url: URL) -> Bool {
        switch url.absoluteString {
        case TextConstants.NotLocalized.termsAndUseEtkLinkTurkcellAndGroupCompanies:
            DispatchQueue.toMain {
                self.output.openTurkcellAndGroupCompanies()
            }
        case TextConstants.NotLocalized.termsAndUseEtkLinkCommercialEmailMessages:
            DispatchQueue.toMain {
                self.output.openCommercialEmailMessages()
            }
        case TextConstants.NotLocalized.privacyPolicyConditions:
            DispatchQueue.toMain {
                self.output.openPrivacyPolicyDescriptionController()
            }
        case TextConstants.NotLocalized.termsOfUseGlobalDataPermLink1:
            DispatchQueue.toMain {
                self.output.openGlobalDataPermissionDetails()
            }
        default:
            UIApplication.shared.openSafely(url)
        }
        return true
    }
}

// MARK: - UITextViewDelegate
extension TermsAndServicesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openSafely(URL)
        return true
    }
}
