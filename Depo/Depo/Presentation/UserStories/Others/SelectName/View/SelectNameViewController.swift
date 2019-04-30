//
//  SelectNameSelectNameViewController.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectNameViewController: BaseViewController, SelectNameViewInput {
    
    var output: SelectNameViewOutput!
    
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = output.getTitle()
        textField.placeholder = output.getPlaceholderText()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: output.getNextButtonText(),
                                                            font: .TurkcellSaturaRegFont(size: 19.0),
                                                            target: self,
                                                            selector: #selector(onNextButton))
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        
        if navigationItem.leftBarButtonItem == nil, navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                               target: self,
                                                               selector: #selector(onCancelButton))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    @objc func onCancelButton() {
        hideView()
    }
    
    func hideView() {
        dismiss(animated: true) {
            
        }
    }
    
    // MARK: SelectNameViewInput
    func setupInitialState() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: Buttons actions
    
    @objc func onNextButton() {
        disableCancelButtonIfNeeded()
        output.onNextButton(name: textField.text ?? "")
    }
    
    private func disableCancelButtonIfNeeded() {
        if textField.text?.isEmpty == true {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}

// MARK: UITextFieldDelegate

extension SelectNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onNextButton()
        return true
    }
}
