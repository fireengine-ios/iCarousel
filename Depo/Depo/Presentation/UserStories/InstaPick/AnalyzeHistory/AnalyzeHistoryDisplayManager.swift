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
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var newAnalysisView: UIView!
    
    var configuration: AnalyzeHistoryDisplayConfiguration = .initial
    
    func applyConfiguration(_ configuration: AnalyzeHistoryDisplayConfiguration) {
        self.configuration = configuration
     
        switch configuration {
        case .initial:
            emptyView.isHidden = true
            newAnalysisView.isHidden = false
        case .empty:
            /// AnalyzeHistoryEmptyCell added to show empty state
            //emptyView.isHidden = false
            newAnalysisView.isHidden = false
            
        case .selection:
            emptyView.isHidden = true
            newAnalysisView.isHidden = true
        }
    }
}
