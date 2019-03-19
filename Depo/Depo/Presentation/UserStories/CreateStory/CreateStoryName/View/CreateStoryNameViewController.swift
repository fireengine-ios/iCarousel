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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        titleLabel.textColor = ColorConstants.darkBlueColor
        titleLabel.text = TextConstants.createStoryNameTitle
        
        storyNameTextField.placeholder = TextConstants.createStoryNamePlaceholder
        storyNameTextField.font = UIFont.TurkcellSaturaRegFont(size: 20)
        
        saveButton.setTitle(TextConstants.createStoryNameSave, for: .normal)
        saveButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
        saveButton.setTitleColor(ColorConstants.blueColor, for: .normal)
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateView()
    }

    private var isShown = false
    private func animateView() {
        if isShown {
            return
        }
        isShown = true
        contentView.transform = NumericConstants.scaleTransform
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.contentView.transform = .identity
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        storyNameTextField.becomeFirstResponder()
    }

    
    // MARK: CreateStoryNameViewInput
    
    func setupInitialState() {
    }
    
    @IBAction func onSaveButton() {
        closeAnimation {
           self.output.onCreateStory(storyName: self.storyNameTextField.text)
        }
    }
    
    @IBAction func onCloseButton() {
        closeAnimation()
    }
    
    private func closeAnimation(completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.contentView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    @IBAction func onCloseKeyboard() {
        storyNameTextField.resignFirstResponder()
    }
    
    // MARK: keyboard 
    
    override func showKeyBoard(notification: NSNotification) {
        super.showKeyBoard(notification: notification)
        let y = contentView.frame.size.height + getMainYForView(view: contentView)
        if (view.frame.size.height - y) < keyboardHeight {
            let dy = keyboardHeight - (view.frame.size.height - y)
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, dy + 10, 0)
            
            //let yText = storyNameTextField.frame.size.height + getMainYForView(view: storyNameTextField)
            let dyText = keyboardHeight - (view.frame.size.height - y) + 10
            if (dyText > 0) {
                let point = CGPoint(x: 0, y: dyText)
                scrollView.setContentOffset(point, animated: true)
            }
        }
    }
    
    override func hideKeyboard() {
        super.hideKeyboard()
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
