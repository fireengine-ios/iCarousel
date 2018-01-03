//
//  FeedbackViewFeedbackViewController.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController, FeedbackViewInput, DropDovnViewDelegate {
    
    @IBOutlet weak var allertView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var suggestionButton: UIButton!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var complaintButton: UIButton!
    @IBOutlet weak var complaintLabel: UILabel!
    @IBOutlet weak var feedbackSubView: UIView!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var dropDovnView: DropDovnView!
    @IBOutlet weak var sendButton: BlueButtonWithWhiteText!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var selectedLanguage = LanguageModel() {
        didSet {
            self.setupTexts()
        }
    }
    private var languagesArray = [LanguageModel]()

    var output: FeedbackViewOutput!
    
    var suggeston: Bool = true
    var complaint: Bool = false

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.languagesArray.append(self.selectedLanguage)
        
        self.setupTexts()
        
        sendButton.isEnabled = false
        
        feedbackTextView.delegate = self
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
        
        dropDovnView.delegate = self
        
        output.viewIsReady()
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
        languageLabel.textColor = ColorConstants.textGrayColor
        
        sendButton.setTitle(TextConstants.feedbackViewSendButton, for: .normal)
        sendButton.titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 14)
        
        suggestionButton.setImage(getImageForChecbox(isSelected: suggeston), for: .normal)
        suggestionButton.tintColor = ColorConstants.blueColor
        
        complaintButton.setImage(getImageForChecbox(isSelected: complaint), for: .normal)
        complaintButton.tintColor = ColorConstants.blueColor
        
        feedbackTextView.textAlignment = .natural
    }
    
    func languagesUploaded(lanuages:[LanguageModel]){
        languagesArray.removeAll()
        languagesArray.append(contentsOf: lanuages)
        languagesArray.sort { (first, _) -> Bool in
            return first.languageCode == self.selectedLanguage.languageCode
        }
        let array = languagesArray.map({ (object) -> String in
            object.displayLanguage ?? ""
        })
        
        if let currentLanguage = languagesArray.first {
            selectedLanguage = currentLanguage
        }
        
        dropDovnView!.setTableDataObjects(objects: array)
    }
    
    func fail(text: String) {
        UIApplication.showErrorAlert(message: text)
    }
    
    func languageRequestSended(text: String){
        if (Mail.canSendEmail()){
            let stringForLetter = String(format: "%@\n\n%@", self.feedbackTextView!.text, text)
            self.dismiss(animated: true, completion: nil)
            Mail.shared().sendEmail(emailBody: stringForLetter, subject: self.getSubject(), emails: [TextConstants.feedbackEmail], success: {
                //
            }, fail: { (error) in
                UIApplication.showErrorAlert(message: error?.localizedDescription ?? TextConstants.feedbackEmailError)
            })
        } else {
            UIApplication.showErrorAlert(message: TextConstants.feedbackEmailError)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dy = (view.frame.size.height - allertView.frame.size.height) * 0.5
        bottomConstraint.constant = dy
        view.layoutIfNeeded()
        animateView()
    }
    
    private var isShown = false
    private func animateView() {
        if isShown {
            return
        }
        isShown = true
        allertView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.allertView.transform = .identity
        }
    }
    
    func setSendButton(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
    }
    
    
    // MARK: Keboard
    
    @IBAction func onHideKeyboard(){
        feedbackTextView.resignFirstResponder()
    }
    
    private func getMainYForView(view: UIView)->CGFloat{
        if (view.superview == self.view){
            return view.frame.origin.y
        }else{
            if (view.superview != nil){
                return view.frame.origin.y + getMainYForView(view:view.superview!)
            }else{
                return 0
            }
        }
    }
    
    @objc func showKeyBoard(notification: NSNotification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let y = allertView.frame.size.height + getMainYForView(view: allertView)
        if (view.frame.size.height - y) < keyboardHeight{
            let dy = keyboardHeight - (view.frame.size.height - y)
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, dy + 10, 0)
            let yText = feedbackTextView.frame.size.height + getMainYForView(view: feedbackTextView)
            let dyText = keyboardHeight - (view.frame.size.height - yText) + 10
            if (dyText > 0){
                let point = CGPoint(x: 0, y: dyText)
                scrollView.setContentOffset(point, animated: true)
            }
            
        }
    }
    
    @objc func hideKeyboard() {
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    // MARK: FeedbackViewViewInput
    func setupInitialState() {
        
    }
    
    
    //MARK: IBActions
    
    func getImageForChecbox(isSelected: Bool) -> UIImage {
        let imageName = isSelected ? "roundSelectedCheckBox" : "roundEmptyCheckBox"
        return UIImage(named:imageName)!.withRenderingMode(.alwaysTemplate)
    }
    
    @IBAction func onCloseButton() {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.allertView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func onSuggestionButton(){
        guard !suggeston else {
            return
        }
        
        toggleButtons()
    }
    
    @IBAction func onComplaintButton(){
        guard !complaint else {
            return
        }
        
        toggleButtons()
    }
    
    @IBAction func onSendButton(){
        if feedbackTextView.text.count > 0 {
            output.onSend(selectedLanguage: selectedLanguage)
        } else {
            let string = TextConstants.feedbackErrorTextError
            
            let controller = UIAlertController(title: TextConstants.feedbackErrorEmptyDataTitle, message: string, preferredStyle: .alert)

            let action = UIAlertAction(title: TextConstants.ok, style: .cancel, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true, completion: {})
        }
    }
    
    func getSubject()-> String{
        if (suggeston){
            return String(format: TextConstants.feedbackViewSubjectFormat, TextConstants.feedbackViewSuggestion)
        }
        if (complaint){
            return String(format: TextConstants.feedbackViewSubjectFormat, TextConstants.feedbackViewComplaint)
        }
        return ""
    }
    
    // MARK: DropDovnViewDelegate
    
    func onSelectItemAtIndx(index: Int){
        if (index < languagesArray.count){
            selectedLanguage = languagesArray[index]
        }
    }
    
    private func toggleButtons() {
        suggeston = !suggeston
        complaint = !complaint
        suggestionButton.setImage(getImageForChecbox(isSelected: suggeston), for: .normal)
        complaintButton.setImage(getImageForChecbox(isSelected: complaint), for: .normal)
    }
    
}


extension FeedbackViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard textView == feedbackTextView else {
            return
        }
        
        output.onTextDidChange(text: textView.text)
    }
}

