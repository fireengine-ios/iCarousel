//
//  DarkPopUpController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 12/11/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class DarkPopUpController: ViewController {

    static func with(title: String?, message: String?, buttonTitle: String, action: ((_: DarkPopUpController) -> Void)? = nil) -> DarkPopUpController {
        
        let vc = DarkPopUpController(nibName: "DarkPopUpController", bundle: nil)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        if let action = action {
            vc.action = action
        }
        vc.alertTitle = title
        vc.alertMessage = message
        vc.buttonTitle = buttonTitle
        
        return vc
    }
    
    @IBOutlet private weak var shadowView: UIView! {
        didSet {
            shadowView.layer.cornerRadius = 8
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 10
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = ColorConstants.darkBlueColor
            titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 20)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = ColorConstants.lightText
            messageLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        didSet {
            actionButton.setTitleColor(UIColor.white, for: .normal)
            actionButton.backgroundColor = ColorConstants.darkBlueColor
            actionButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
            actionButton.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    
    private var alertTitle: String?
    private var alertMessage: String?
    private var buttonTitle = ""
    
    lazy var action: (_ vc: DarkPopUpController) -> Void = { vc in
        vc.close()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        titleLabel.text = alertTitle
        messageLabel.text = alertMessage
        actionButton.setTitle(buttonTitle, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }
    
    private var isShown = false
    private func open() {
        if isShown {
            return
        }
        isShown = true
        shadowView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.shadowView.transform = .identity
        }
    }
    
    func close(animation: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.shadowView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: animation)
        }
    }

    
    @IBAction func actionCloseButton(_ sender: UIButton) {
        close()
    }
    
    @IBAction func actionButton(_ sender: UIButton) {
        action(self)
    }
}
