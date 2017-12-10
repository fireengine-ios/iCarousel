//
//  SelectNameSelectNameViewController.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectNameViewController: BaseViewController, SelectNameViewInput, UITextFieldDelegate {

    var output: SelectNameViewOutput!
    
    let custoPopUp = CustomPopUp()
    
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    
    @IBOutlet weak var textField: UITextField!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = output.getTitle()
        textField.placeholder = output.getPlaceholderText()
        
        let rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        rightButton.setTitle(output.getNextButtonText(), for: .normal)
        rightButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        rightButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        rightButton.titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        let barButton = UIBarButtonItem(customView: rightButton)
        navigationItem.rightBarButtonItem = barButton
        
        cancelButton.setTitle(TextConstants.selectFolderCancelButton, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        
        if navigationItem.leftBarButtonItem == nil && navigationController?.viewControllers.count == 1{
            let barButtonLeft = UIBarButtonItem(customView: cancelButton)
            navigationItem.leftBarButtonItem = barButtonLeft
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    @objc func onCancelButton(){
        hideView()
    }
    
    func hideView(){
        dismiss(animated: true) {
            
        }
    }

    // MARK: SelectNameViewInput
    func setupInitialState() {
        
    }
    
    
    // MARK: Buttons actions
    
    @objc func onNextButton(){
        textField.resignFirstResponder()
        
        var flag = false
        if let string = textField.text{
            if (string.count != 0) {
                output.onNextButton(name: string)
                flag = true
            }
        }
        
        if (!flag){
            custoPopUp.showCustomAlert(withText: output.getTextForEmptyTextFieldAllert(),
                                       okButtonText: TextConstants.ok)
        }
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onNextButton()
        return true
    }
    
}
