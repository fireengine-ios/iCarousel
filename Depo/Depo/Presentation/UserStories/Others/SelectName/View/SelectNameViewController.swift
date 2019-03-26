//
//  SelectNameSelectNameViewController.swift
//  Depo
//
//  Created by Oleg on 15/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class SelectNameViewController: BaseViewController {
    var output: SelectNameViewOutput!
    
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Life cycle
    
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

    // MARK: - Buttons actions
    
    @objc func onNextButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        textField.resignFirstResponder()
        output.onNextButton(name: textField.text ?? "")
    }
    
    @objc func onCancelButton() {
        hideView()
    }
}

// MARK: - SelectNameViewInput

extension SelectNameViewController: SelectNameViewInput {
    func setupInitialState() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func hideView() {
        dismiss(animated: true) {
        }
    }
}
