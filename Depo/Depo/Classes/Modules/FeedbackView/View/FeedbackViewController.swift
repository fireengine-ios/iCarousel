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
    
    private var selectedLanguage: LanguageModel? = nil
    private var languagesArray = [LanguageModel]()

    var output: FeedbackViewOutput!
    
    var suggeston: Bool = false
    var complaint: Bool = false

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        suggestionButton.setImage(getImageForChecbox(isSelected: false), for: .normal)
        suggestionButton.setImage(getImageForChecbox(isSelected: true), for: .selected)
        suggestionButton.tintColor = ColorConstants.blueColor
        
        complaintButton.setImage(getImageForChecbox(isSelected: false), for: .normal)
        complaintButton.setImage(getImageForChecbox(isSelected: true), for: .selected)
        complaintButton.tintColor = ColorConstants.blueColor
        
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
    
    func languagesUploaded(lanuages:[LanguageModel]){
        languagesArray.removeAll()
        languagesArray.append(contentsOf: lanuages)
        let array = lanuages.map({ (object) -> String in
            object.displayLanguage ?? ""
        })
        dropDovnView!.setTableDataObjects(objects: array)
    }
    
    func fail(text: String){
        CustomPopUp.sharedInstance.showCustomAlert(withText: text, okButtonText: TextConstants.ok)
    }
    
    func languageRequestSended(text: String){
        if (Mail.canSendEmail()){
            UIView.animate(withDuration: NumericConstants.durationOfAnimation, animations: {
                self.view.alpha = 0
            }, completion: {[weak self] (flag) in
                guard let self_ = self else{
                    return
                }
                let stringForLetter = String(format: "%@\n\n%@", self_.feedbackTextView!.text, text)
                Mail.shared().sendEmail(emailBody: stringForLetter,
                                        subject: self_.getSubject(),
                                        emails: [TextConstants.feedbackEmail])
                self_.view.removeFromSuperview()
            })
        }else{
            CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.feedbackEmailError, okButtonText: TextConstants.ok)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let dy = (view.frame.size.height - allertView.frame.size.height) * 0.5
        bottomConstraint.constant = dy
        view.layoutIfNeeded()
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
    
    @IBAction func onCloseButton(){
        UIView.animate(withDuration: NumericConstants.durationOfAnimation, animations: {
            self.view.alpha = 0
        }) { (flag) in
            self.view.removeFromSuperview()
        }
        
    }
    
    @IBAction func onSuggestionButton(){
        if (complaint){
            onComplaintButton()
        }
        suggeston = !suggeston
        suggestionButton.setImage(getImageForChecbox(isSelected: suggeston), for: .normal)
    }
    
    @IBAction func onComplaintButton(){
        if (suggeston){
            onSuggestionButton()
        }
        complaint = !complaint
        complaintButton.setImage(getImageForChecbox(isSelected: complaint), for: .normal)
    }
    
    @IBAction func onSendButton(){
        if (selectedLanguage != nil)&&(feedbackTextView.text.characters.count > 0){
            output.onSend(selectedLanguage: selectedLanguage!)
        }else{
            var string = ""
            if (selectedLanguage == nil){
                string = TextConstants.feedbackErrorLanguageError
            }else{
                string = TextConstants.feedbackErrorTextError
            }
            let controller = UIAlertController(title: TextConstants.feedbackErrorEmptyDataTitle, message: string, preferredStyle: .alert)

            let action = UIAlertAction(title: TextConstants.ok, style: .cancel, handler: { (action) in
                self.dismiss(animated: true, completion: {
                    
                })
            })
            controller.addAction(action)
            self.present(controller, animated: true, completion: {})
        }
    }
    
    func getSubject()-> String{
        if (suggeston){
            return TextConstants.feedbackViewSuggestion
        }
        if (complaint){
            return TextConstants.feedbackViewComplaint
        }
        return ""
    }
    
    // MARK: DropDovnViewDelegate
    
    func onSelectItemAtIndx(index: Int){
        if (index < languagesArray.count){
            selectedLanguage = languagesArray[index]
        }
    }
    
}
