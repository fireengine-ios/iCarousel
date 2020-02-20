//
//  BlurBackgroundPopup.swift
//  Depo
//
//  Created by Andrei Novikau on 8/13/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class BlurBackgroundPopup: BaseViewController, NibInit {
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dismissButton: InsetsButton! {
        willSet {
            newValue.layer.masksToBounds = true
            
            newValue.adjustsFontSizeToFitWidth()
            newValue.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            newValue.titleLabel?.textAlignment = .center
            newValue.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var actionButton: InsetsButton! {
        willSet {
            newValue.layer.masksToBounds = true
            
            newValue.adjustsFontSizeToFitWidth()
            newValue.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            newValue.titleLabel?.textAlignment = .center
            newValue.addTarget(self, action: #selector(onAction), for: .touchUpInside)
        }
    }
    
    private var blurBackgroundView: UIVisualEffectView!
    
    private var action: VoidHandler?
    private var dismissAction: VoidHandler?
    
    // MARK: - View lifecycle
    
    func setup(action: VoidHandler?, dismissAction: VoidHandler?) {
        self.action = action
        self.dismissAction = dismissAction
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.alpha = 0
        setupBlurView()
        setupTitleLabel()
        setupDismissButton()
        setupActionButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.contentView.alpha = 1
            self.blurBackgroundView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    private func setupBlurView() {
        blurBackgroundView = UIVisualEffectView(effect: nil)
        view.addSubview(blurBackgroundView)
        view.sendSubview(toBack: blurBackgroundView)
        blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        blurBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).activate()
        blurBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).activate()
        blurBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        blurBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
    }
    
    func setupTitleLabel() {}
    func setupDismissButton() {}
    func setupActionButton() {}
    
    // MARK: - Actions
    
    @objc private func onCancel() {
        close {
            self.dismissAction?()
        }
    }
    
    @objc private func onAction() {
        close {
            self.action?()
        }
    }
    
    private func close(_ completion: VoidHandler? = nil) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.contentView.alpha = 0
            self.blurBackgroundView.effect = nil
        }, completion: { _ in
            self.dismiss(animated: false, completion: completion)
        })
    }
}
