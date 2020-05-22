//
//  ContactSyncViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactSyncViewController: BaseViewController, NibInit {
    
    private var foobar = false
    
    @IBOutlet private weak var contentView: UIView!
    
    private var tabBarIsVisible = false
    
    private lazy var noBackupView: ContactSyncNoBackupView = {
        let view = ContactSyncNoBackupView.initFromNib()
        view.delegate = self
        return view
    }()
    
    private lazy var mainView: ContactSyncMainView = {
        let view = ContactSyncMainView.initFromNib()
//        view.delegate = self
        return view
    }()
    
    private var animator = ContentViewAnimator()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarIsVisible {
            needToShowTabBar = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        setupContentView()
    }
    
    private func setupNavBar() {
        if tabBarIsVisible {
            homePageNavigationBarStyle()
        } else {
            navigationBarWithGradientStyle()
            setTitle(withString: TextConstants.backUpMyContacts)
        }
    }
    
    private func setupContentView() {
        showSpinner()
        getBackups { [weak self] hasBackup in
            guard let self = self else {
                return
            }
            self.hideSpinner()
            self.foobar = hasBackup
            self.showRelatedView()
        }
    }
    
    private func showRelatedView() {
        //TODO: make real
        if foobar {
            self.mainView.update()
            self.show(view: self.mainView, animated: true)
        } else {
            self.show(view: self.noBackupView, animated: true)
        }
    }
    
    private func getBackups(completion: @escaping BoolHandler) {
        //TODO: make real
        DispatchQueue.toBackground {
            completion(false)
        }
    }
    
    private func show(view: UIView, animated: Bool) {
        animator.showTransition(to: view, on: contentView, animated: true)
    }
    
    
    //MARK: - Public
    
    func setTabBar(isVisible: Bool) {
        tabBarIsVisible = isVisible
    }

}


extension ContactSyncViewController: ContactSyncNoBackupViewDelegate {
    func didTouchBackupButton() {
        //TODO: Open BackUp screen
        foobar = true
        showRelatedView()
    }
}



private class ContentViewAnimator {
    
    func showTransition(to newView: UIView, on contentView: UIView, animated: Bool) {
        let currentView = contentView.subviews.first
        
        guard newView != currentView else {
            return
        }
        
        DispatchQueue.main.async {
            newView.frame = contentView.bounds
            
            if let oldView = currentView {
                let duration = animated ? 0.25 : 0.0
                UIView.transition(from: oldView, to: newView, duration: duration, options: [.curveLinear], completion: nil)
            } else {
                contentView.addSubview(newView)
            }
        }
    }
}
