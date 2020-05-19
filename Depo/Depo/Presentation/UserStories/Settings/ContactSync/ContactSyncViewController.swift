//
//  ContactSyncViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 19.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class ContactSyncViewController: ViewController, NibInit {
    
    private lazy var noBackupView: ContactSyncNoBackupView = {
        return ContactSyncNoBackupView.initFromNib()
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSpinner()
        getBackups { [weak self] hasBackup in
            guard let self = self else {
                return
            }
            self.hideSpinner()
            
            if hasBackup {
                
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        self.view = self.noBackupView
                    }
                }
            }
        }
    }
    
    private func getBackups(completion: @escaping BoolHandler) {
        DispatchQueue.toBackground {
            completion(false)
        }
    }

}
