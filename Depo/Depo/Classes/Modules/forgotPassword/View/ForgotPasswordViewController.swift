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
    
    @IBOutlet weak var sendPasswordButton:UIButton!
    @IBOutlet weak var subTitle:UILabel!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var viewForCapcha:UIView!
    @IBOutlet weak var capchaViewH:NSLayoutConstraint!
    @IBOutlet weak var bottomSpace:NSLayoutConstraint!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = TextConstants.forgotPasswordTitle
        
        self.tableView?.backgroundColor = UIColor.clear
        
        sendPasswordButton.backgroundColor = ColorConstants.whiteColor
        sendPasswordButton.setTitle(TextConstants.forgotPasswordSendPassword, for: UIControlState.normal)
        sendPasswordButton.setTitleColor(ColorConstants.blueColor, for: UIControlState.normal)
        sendPasswordButton.layer.cornerRadius = sendPasswordButton.frame.size.height * 0.5
        sendPasswordButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 20)
        
        subTitle.text = TextConstants.forgotPasswordSubTitle
        subTitle.textColor = ColorConstants.whiteColor
        subTitle.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 15)
        
        let nib = UINib(nibName: "inputCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CellsIdConstants.baseUserInputCellViewID)
        
        output.viewIsReady()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    // MARK: IN
    func setupInitialState() {
        
    }
    
    func showCapcha(){
        UIView.animate(withDuration: 0.3) {
            let dyTop = CGFloat(100.0)
            var dyBottom = CGFloat(0.0)
            if (self.subTitle.frame.origin.y < 164.0){
                dyBottom = CGFloat(164.0) - abs(self.subTitle.frame.origin.y)
                self.bottomSpace.constant = dyBottom
            }
            self.capchaViewH.constant = dyTop
            self.view.layoutIfNeeded()
        }
        
    }
    
    //MARK: Buttons actions 
    
    @IBAction func onSendPasswordButton(){
        endEditing()
        output.onSendPassword()
        showCapcha()
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
        cell.textInputField.returnKeyType = .next
        cell.textInputField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: ColorConstants.whiteColor])
        return cell
    }
    
    // MARK: ProtoInputCellProtocol
    
    func textFinishedEditing(withCell cell: ProtoInputTextCell){
        endEditing()
    }
    
}
