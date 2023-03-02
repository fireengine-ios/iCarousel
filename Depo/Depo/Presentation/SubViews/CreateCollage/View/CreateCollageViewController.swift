//
//  CreateCollageViewController.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class CreateCollageViewController: BaseViewController {
    
    var output: CreateCollageViewOutput!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("CreateCollage viewDidLoad")
        
        setTitle(withString: "Create Collage")
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        
        output.viewIsReady()
    }
    
}


extension CreateCollageViewController: ShareCardContentManagerDelegate {
    func shareOperationStarted() {
        showSpinner()
    }
    
    func shareOperationFinished() {
        hideSpinner()
    }
}

extension CreateCollageViewController: CreateCollageViewInput {
    func didFinishedAllRequests() {
        DispatchQueue.main.async {
            print("aaaa123123")
            //self.tableView.reloadData()
        }
    }
}
