//
//  ForgotPasswordForgotPasswordViewController.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, ForgotPasswordViewInput, UITableViewDelegate, UITableViewDataSource, ProtoInputCellProtocol {

    var output: ForgotPasswordViewOutput!
    
    @IBOutlet weak var sendPasswordButton:WhiteButtonWithRoundedCorner!
    @IBOutlet weak var subTitle:UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var viewForCapcha:UIView!
    @IBOutlet weak var capchaViewH:NSLayoutConstraint!
    @IBOutlet weak var bottomSpace:NSLayoutConstraint!
    @IBOutlet weak var scrollView:UIScrollView!
    
    var captchaModuleView = CaptchaViewController.initFromXib()
    
    private var originBottomH:CGFloat = -1

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if !Device.isIpad {
            setNavigationTitle(title: TextConstants.forgotPasswordTitle)
        }
        self.tableView?.backgroundColor = UIColor.clear
        
        sendPasswordButton.setTitle(TextConstants.forgotPasswordSendPassword, for: UIControlState.normal)
        
        
        
        let nib = UINib(nibName: "inputCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.baseUserInputCellViewID)
        
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        viewForCapcha.addSubview(captchaModuleView.view)
        captchaModuleView.view.frame = viewForCapcha.bounds
        capchaViewH.constant = 132
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visibleNavigationBarStyle()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyBoard),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
         NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        originBottomH = bottomSpace.constant
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        guard let baseCell = cell as? BaseUserInputCellView else {
            return
        }
        baseCell.textInputField.becomeFirstResponder()

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }
    
    func endEditing(){
        view.endEditing(true)
    }
    
    func setupVisableSubTitle() {
        setupSubTitle()
    }
    
    private func setupSubTitle() {
        subTitle.isHidden = false
        subTitle.text = TextConstants.forgotPasswordSubTitle
        subTitle.textColor = ColorConstants.whiteColor
        if (Device.isIpad){
            
            subTitle.font = UIFont.TurkcellSaturaDemFont(size: 24)
        }else{
            subTitle.font = UIFont.TurkcellSaturaDemFont(size: 16)
            subTitle.textAlignment = .left
        }
    }
    
    @objc func showKeyBoard(notification: NSNotification){
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let yNextButton = getMainYForView(view: sendPasswordButton) + sendPasswordButton.frame.size.height
        if (view.frame.size.height - yNextButton < keyboardHeight){
            
            bottomSpace.constant = keyboardHeight + 40.0
            view.layoutIfNeeded()
            
            
            let textField = searchActiveTextField(view: self.view)
            if (textField != nil){
                let yOfTextField = getMainYForView(view: textField!) + textField!.frame.size.height + 20
                if (yOfTextField > view.frame.size.height - keyboardHeight){
                    let dy = yOfTextField - (view.frame.size.height - keyboardHeight)
                    
                    let point = CGPoint(x: 0, y: dy + 10)
                    scrollView.setContentOffset(point, animated: true)
                }
            }
        }
    }
    
    private func searchActiveTextField(view: UIView) -> UITextField? {
        
        if let textField = view as? UITextField {
            if textField.isFirstResponder {
                return textField
            }
        }
        for subView in view.subviews {
            let textField = searchActiveTextField(view: subView)
            if (textField != nil){
                return textField
            }
        }
        return nil
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
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        bottomSpace.constant = self.originBottomH
        view.layoutIfNeeded()
    }
    

    // MARK: IN
    func setupInitialState() {
        
    }
    
    func showCapcha(){
//        UIView.animate(withDuration: 0.3) {
//            let dyTop = CGFloat(100.0)
//            var dyBottom = CGFloat(0.0)
//            if (self.subTitle.frame.origin.y < 164.0){
//                dyBottom = CGFloat(164.0) - abs(self.subTitle.frame.origin.y)
//                self.bottomSpace.constant = dyBottom
//            }
//            self.capchaViewH.constant = dyTop
//            self.view.layoutIfNeeded()
//        }
        
    }
    
    //MARK: Buttons actions 
    
    @IBAction func onSendPasswordButton(){
        endEditing()
        let captchaUdid = captchaModuleView.currenrtCapthcaID
        let captchaEntered = captchaModuleView.inputTextField.text
        output.onSendPassword(withEmail: obtainEmail(), enteredCaptcha: captchaEntered ?? "", captchaUDID: captchaUdid)
        showCapcha()
    }
    
    private func obtainEmail() -> String {
        let mailCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! BaseUserInputCellView
        
        return mailCell.textInputField.text ?? ""
    }
    
    
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.baseUserInputCellViewID,
                                                 for: indexPath) as! BaseUserInputCellView
        cell.textDelegate = self
        cell.titleLabel.textColor = ColorConstants.whiteColor
        cell.titleLabel.text = TextConstants.forgotPasswordCellTitle
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textInputField.returnKeyType = .done
        cell.textInputField.autocorrectionType = .no
        cell.textInputField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.whiteColor])
        return cell
    }
    
    // MARK: ProtoInputCellProtocol
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell){
        endEditing()
    }
    
    func textStartedEditing(withCell cell: ProtoInputTextCell) {
        // TODO : OLEG
        if (view.frame.size.height <= 568){
            let index = tableView.indexPath(for: cell)
            
            var topY = scrollView.frame.origin.y + tableView.frame.origin.y
            topY = topY + CGFloat((index?.row)! + 1) * cell.frame.size.height
            let dy = view.frame.size.height - 216
            var y: CGFloat = 0
            if (dy < topY){
                y = (topY - dy)
            }
            let point = CGPoint(x: 0, y: y)
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
}
