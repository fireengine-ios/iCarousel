//
//  AugumentRealityDetailViewController.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook


final class AugmentedRealityController: QLPreviewController {
    
    var source: AugmentedRealityDataSource?
    
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSource()
        udpateARItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        source?.removeLocalFile()
    }
    
    
    private func setupSource() {
        source?.delegate = self
        dataSource = source
    }
    
    private func udpateARItem() {
        showSpinerWithCancelClosure {
            self.dismiss(animated: true, completion: nil)
        }
        source?.updateARItem()
    }
}


extension AugmentedRealityController: AugmentedRealityDataSourceDelegate {
    func didUpdateARItem() {
        hideSpinnerIncludeNavigationBar()
        DispatchQueue.toMain {
            self.reloadData()
        }
    }
    
    func didFailToUpdateARItem(with errorMessage: String?) {
        hideSpinnerIncludeNavigationBar()
    }
}
