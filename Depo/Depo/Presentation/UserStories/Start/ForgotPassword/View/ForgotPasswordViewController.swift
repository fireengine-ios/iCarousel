//
//  ForgotPasswordForgotPasswordViewController.swift
//  Depo
//
//  Created by Oleg on 15/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import Typist

class ForgotPasswordViewController: ViewController, ForgotPasswordViewInput, UITableViewDelegate, UITableViewDataSource, ProtoInputCellProtocol {

    var output: ForgotPasswordViewOutput!
    
    @IBOutlet weak var sendPasswordButton: WhiteButtonWithRoundedCorner!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewForCapcha: UIView!
    @IBOutlet weak var capchaViewH: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var captchaModuleView = CaptchaViewController.initFromXib()
    
    private var originBottomH: CGFloat = -1

    fileprivate let keyboard = Typist.shared

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
        
        configureKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hidenNavigationBarStyle()
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
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    func setupVisableSubTitle() {
        setupSubTitle()
    }
    
    private func setupSubTitle() {
        subTitle.isHidden = false
        
        if Locale.current.languageCode == "en" || Locale.current.languageCode == "tr" {
            subTitle.text = TextConstants.forgotPasswordSubTitle
        } else {
            subTitle.text = ""
        }
        
        subTitle.textColor = ColorConstants.whiteColor
        if (Device.isIpad) {
            
            subTitle.font = UIFont.TurkcellSaturaDemFont(size: 24)
        } else {
            subTitle.font = UIFont.TurkcellSaturaDemFont(size: 16)
            subTitle.textAlignment = .left
        }
    }
    
    deinit {
        keyboard.stop()
    }
    
    fileprivate func configureKeyboard() {
        
        keyboard.on(event: .didChangeFrame) { [weak self] options in
            guard let wSelf = self else {
                return
            }
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: options.endFrame.height + UIScreen.main.bounds.height - options.endFrame.maxY, right: 0)
            wSelf.scrollView.contentInset = insets
            wSelf.scrollView.scrollIndicatorInsets = insets
            
            let bottomOffset = CGPoint(x: 0, y: wSelf.scrollView.contentSize.height - wSelf.scrollView.bounds.size.height + wSelf.scrollView.contentInset.bottom)
            if(bottomOffset.y > 0) {
                wSelf.scrollView.setContentOffset(bottomOffset, animated: true)
            }
            }
            .on(event: .willHide) { [weak self] _ in
                guard let wSelf = self else {
                    return
                }
                var inset = wSelf.scrollView.contentInset
                inset.bottom = 0

                wSelf.scrollView.contentInset = inset
                wSelf.scrollView.setContentOffset(CGPoint.zero, animated: true)
            }
            .start()
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        bottomSpace.constant = self.originBottomH
        view.layoutIfNeeded()
    }
    

    // MARK: IN
    func setupInitialState() {
        
    }
    
    func showCapcha() {
        captchaModuleView.refreshCapthcha()
        captchaModuleView.inputTextField.text = ""
//        UIView.animate(withDuration: NumericConstants.animationDuration) {
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
    
    // MARK: Buttons actions 
    
    @IBAction func onSendPasswordButton() {
        endEditing()
        let captchaUdid = captchaModuleView.currentCaptchaID
        let captchaEntered = captchaModuleView.inputTextField.text
        output.onSendPassword(withEmail: obtainEmail(), enteredCaptcha: captchaEntered ?? "", captchaUDID: captchaUdid)
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
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell) {
        endEditing()
    }
    
    func textStartedEditing(withCell cell: ProtoInputTextCell) {
        // TODO : OLEG
        if (view.frame.size.height <= 568) {
            let index = tableView.indexPath(for: cell)
            
            var topY = scrollView.frame.origin.y + tableView.frame.origin.y
            topY = topY + CGFloat((index?.row)! + 1) * cell.frame.size.height
            let dy = view.frame.size.height - 216
            var y: CGFloat = 0
            if (dy < topY) {
                y = (topY - dy)
            }
            let point = CGPoint(x: 0, y: y)
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
}
