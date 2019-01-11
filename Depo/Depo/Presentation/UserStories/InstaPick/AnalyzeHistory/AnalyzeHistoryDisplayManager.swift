//
//  AnalyzeHistoryDisplayManager.swift
//  Depo
//
//  Created by Andrei Novikau on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum AnalyzeHistoryDisplayConfiguration {
    case initial
    case empty
    case selection    
}

final class AnalyzeHistoryDisplayManager: NSObject {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyView: UIView!
    
    var configuration: AnalyzeHistoryDisplayConfiguration = .initial
    
    func applyConfiguration(_ configuration: AnalyzeHistoryDisplayConfiguration) {
        self.configuration = configuration
     
        switch configuration {
        case .initial:
            emptyView.isHidden = true
            
        case .empty:
            emptyView.isHidden = false
            
        case .selection:
            emptyView.isHidden = true
            collectionView.reloadData()
        }
    }
}
