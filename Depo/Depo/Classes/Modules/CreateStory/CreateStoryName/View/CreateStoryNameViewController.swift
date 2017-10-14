//
//  CreateStoryNameCreateStoryNameViewController.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class CreateStoryNameViewController: BaseViewController, CreateStoryNameViewInput {

    var output: CreateStoryNameViewOutput!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    @IBOutlet weak var saveButton: BlueButtonWithWhiteText!
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        titleLabel.textColor = ColorConstants.darcBlueColor
        titleLabel.text = TextConstants.createStoryNameTitle
        
        storyNameTextField.placeholder = TextConstants.createStoryNamePlaceholder
        storyNameTextField.font = UIFont.TurkcellSaturaRegFont(size: 20)
        
        saveButton.setTitle(TextConstants.createStoryNameSave, for: .normal)
        
        output.viewIsReady()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        storyNameTextField.becomeFirstResponder()
    }

    
    // MARK: CreateStoryNameViewInput
    
    func setupInitialState() {
    }
    
    @IBAction func onSaveButton() {
        output.onCreateStory(storyName: storyNameTextField.text)
        
        view.removeFromSuperview()
    }
    
    @IBAction func onCloseButton(){
        UIView.animate(withDuration: NumericConstants.durationOfAnimation, animations: {
            self.view.alpha = 0
        }) {[weak self] (flag) in
            guard let self_ = self
                else {
                return
            }
            self_.view.removeFromSuperview()
        }
    }
    
    @IBAction func onCloseKeyboard(){
        storyNameTextField.resignFirstResponder()
    }
    
    // MARK: keyboard 
    
    override func showKeyBoard(notification: NSNotification){
        super .showKeyBoard(notification: notification)
        
        let y = contentView.frame.size.height + getMainYForView(view: contentView)
        if (view.frame.size.height - y) < keyboardHeight {
            let dy = keyboardHeight - (view.frame.size.height - y)
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, dy + 10, 0)
            
            let yText = storyNameTextField.frame.size.height + getMainYForView(view: storyNameTextField)
            let dyText = keyboardHeight - (view.frame.size.height - yText) + 10
            if (dyText > 0){
                let point = CGPoint(x: 0, y: dyText)
                scrollView.setContentOffset(point, animated: true)
            }
        }
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
