//
//  FeedbackViewFeedbackViewController.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FeedbackViewController: ViewController {
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var suggestionButton: UIButton!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var complaintButton: UIButton!
    @IBOutlet weak var complaintLabel: UILabel!
    @IBOutlet weak var feedbackSubView: UIView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var dropDownView: DropDownView!
    @IBOutlet weak var sendButton: BlueButtonWithWhiteText!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var selectedLanguage: LanguageModel? {
        didSet {
            self.setupTexts()
        }
    }
    private var availableLanguages = [LanguageModel]()

    var output: FeedbackViewOutput!
    
    private var suggeston = true
    private var complaint = false
    private var isShown = false

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTexts()
        
        feedbackTextView.delegate = self
        dropDownView.delegate = self
        
        feedbackSubView.layer.cornerRadius = 4
        feedbackTextView.layer.cornerRadius = 4
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationBarWithGradientStyle()
        bottomConstraint.constant = (view.frame.height - alertView.frame.height) * 0.5
        view.layoutIfNeeded()
        animateView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTexts() {
        //TODO: use self.selectedLanguage
        
        titleLabel.text = TextConstants.feedbackViewTitle
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        titleLabel.textColor = ColorConstants.whiteColor
        
        subTitle.text = TextConstants.feedbackViewSubTitle
        subTitle.font = UIFont.TurkcellSaturaRegFont(size: 18)
        subTitle.textColor = ColorConstants.textGrayColor
        
        suggestionLabel.text = TextConstants.feedbackViewSuggestion
        suggestionLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        suggestionLabel.textColor = ColorConstants.textGrayColor
        
        complaintLabel.text = TextConstants.feedbackViewComplaint
        complaintLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        complaintLabel.textColor = ColorConstants.textGrayColor
        
        languageLabel.text = TextConstants.feedbackViewLanguageLabel
        languageLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        languageLabel.adjustsFontSizeToFitWidth()
        languageLabel.textColor = ColorConstants.textGrayColor
        
        sendButton.setTitle(TextConstants.feedbackViewSendButton, for: .normal)
        sendButton.titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 14)
        
        suggestionButton.setImage(getImageForCheckbox(isSelected: suggeston), for: .normal)
        suggestionButton.tintColor = ColorConstants.blueColor
        
        complaintButton.setImage(getImageForCheckbox(isSelected: complaint), for: .normal)
        complaintButton.tintColor = ColorConstants.blueColor
        
        feedbackTextView.textAlignment = .natural
    }
    
    private func animateView() {
        if isShown {
            return
        }
        isShown = true
        alertView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.alertView.transform = .identity
        }
    }
    
    private func toggleButtons() {
        suggeston = !suggeston
        complaint = !complaint
        suggestionButton.setImage(getImageForCheckbox(isSelected: suggeston), for: .normal)
        complaintButton.setImage(getImageForCheckbox(isSelected: complaint), for: .normal)
    }
    
    // MARK: Keyboard
    
    private func getMainYForView(view: UIView) -> CGFloat {
        if (view.superview == self.view) {
            return view.frame.origin.y
        } else {
            if (view.superview != nil) {
                return view.frame.origin.y + getMainYForView(view: view.superview!)
            } else {
                return 0
            }
        }
    }
    
    @objc func showKeyBoard(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let y = alertView.frame.size.height + getMainYForView(view: alertView)
        
        if (view.frame.size.height - y) < keyboardHeight {
            let dy = keyboardHeight - (view.frame.size.height - y)
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, dy + 10, 0)
            let yText = feedbackTextView.frame.size.height + getMainYForView(view: feedbackTextView)
            let dyText = keyboardHeight - (view.frame.size.height - yText) + 10
            if (dyText > 0) {
                let point = CGPoint(x: 0, y: dyText)
                scrollView.setContentOffset(point, animated: true)
            }
        }
    }
    
    @objc func hideKeyboard() {
        self.scrollView.contentInset = .zero
    }
    
    // MARK: IBActions
    
    func getImageForCheckbox(isSelected: Bool) -> UIImage {
        let imageName = isSelected ? "roundSelectedCheckBox" : "roundEmptyCheckBox"
        return UIImage(named: imageName)!.withRenderingMode(.alwaysTemplate)
    }
    
    @IBAction func onCloseButton() {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.alertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func onSuggestionButton() {
        guard !suggeston else {
            return
        }
        
        toggleButtons()
    }
    
    @IBAction func onComplaintButton() {
        guard !complaint else {
            return
        }
        
        toggleButtons()
    }
    
    @IBAction func onSendButton() {
        guard !feedbackTextView.text.isEmpty else {
            UIApplication.showErrorAlert(message: TextConstants.feedbackErrorTextError)
            return
        }
        guard let selectedLanguage = selectedLanguage else {
            UIApplication.showErrorAlert(message: TextConstants.feedbackErrorLanguageError)
            return
        }
        view.endEditing(true)
        output.onSend(selectedLanguage: selectedLanguage)
    }
    
    func getSubject() -> String {
        if suggeston {
            return String(format: TextConstants.feedbackViewSubjectFormat, TextConstants.feedbackViewSuggestion)
        }
        if complaint {
            return String(format: TextConstants.feedbackViewSubjectFormat, TextConstants.feedbackViewComplaint)
        }
        return ""
    }
}

extension FeedbackViewController: DropDownViewDelegate {
    func onWillShow() {
        feedbackTextView.resignFirstResponder()
    }
    
    func onSelectItem(atIndex index: Int) {
        if index < availableLanguages.count {
            selectedLanguage = availableLanguages[index]
        }
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        dropDownView.hideViewIfNeeded()
        return true
    }
}

extension FeedbackViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: dropDownView)
        return !dropDownView.containsPoint(location)
    }
}

// MARK: FeedbackViewInput

extension FeedbackViewController: FeedbackViewInput {    
    func languagesUploaded(languages: [LanguageModel]) {
        availableLanguages.removeAll()
        availableLanguages.append(contentsOf: languages)
        
        let array = availableLanguages.map({ object -> String in
            object.displayLanguage ?? ""
        })
        
        if let languageCode = NSLocale.current.languageCode, languageCode == "tr",
            let currentLanguage = availableLanguages.first(where: { $0.languageCode == "tr" }) {
            selectedLanguage = currentLanguage
        }
        
        dropDownView.setTableDataObjects(objects: array, defaultObject: selectedLanguage?.displayLanguage)
    }

    func fail(text: String) {
        UIApplication.showErrorAlert(message: text)
    }
    
    func languageRequestSended(email: String, text: String) {
        if Mail.canSendEmail() {
            let stringForLetter = String(format: "%@\n\n%@", self.feedbackTextView!.text, text)
            self.dismiss(animated: true, completion: nil)
            Mail.shared().sendEmail(emailBody: stringForLetter, subject: self.getSubject(), emails: [email], success: {
                //
            }, fail: { error in
                UIApplication.showErrorAlert(message: error?.description ?? TextConstants.feedbackEmailError)
            })
        } else {
            UIApplication.showErrorAlert(message: TextConstants.feedbackEmailError)
        }
    }
    
    func setSendButton(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
    }
}
