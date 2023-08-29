//
//  PhotoPrintViewController.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class PhotoPrintViewController: BaseViewController {
    
    var output: PhotoPrintViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("PhotoPrintViewController viewDidLoad")
        
        setTitle(withString: localized(.createCollageLabel))
        view.backgroundColor = AppColor.background.color
    }
    
    private func configureTableView() {
    }
}

extension PhotoPrintViewController: PhotoPrintViewInput {
    func didFinishedAllRequests() {
    }
}

extension PhotoPrintViewController: PhotoPrintViewOutput {
    func getSectionsCountAndName() {
        
    }
    
    func viewIsReady() {
        
    }
}
