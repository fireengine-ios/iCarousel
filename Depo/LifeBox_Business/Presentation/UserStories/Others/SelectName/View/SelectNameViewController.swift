//
//  SelectNameSelectNameViewController.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectNameViewController: BaseViewController, SelectNameViewInput, NibInit {
    
    var output: SelectNameViewOutput!
    
    @IBOutlet weak var textField: UITextField!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = output.getTitle()
        textField.placeholder = output.getPlaceholderText()
        
        setNavigationRightBarButton(style: .white, title: output.getNextButtonText(), image: nil, target: self, action: #selector(onNextButton))
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBarStyle(.white)

        if isModal() {
            setNavigationLeftBarButton(style: .white, title: TextConstants.selectFolderCancelButton, target: self, image: nil, action: #selector(onCancelButton))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    @objc func onCancelButton() {
        hideView(completion: nil)
    }
    
    func hideView(completion: VoidHandler?) {
        dismiss(animated: true, completion: completion)
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
        let textFieldIsEmpty = textField.text?.isEmpty ?? false
        navigationItem.rightBarButtonItem?.isEnabled = textFieldIsEmpty
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
