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
    @IBOutlet private weak var startHereView: UIView!
    
    var configuration: AnalyzeHistoryDisplayConfiguration = .initial
    
    func applyConfiguration(_ configuration: AnalyzeHistoryDisplayConfiguration) {
        self.configuration = configuration
     
        switch configuration {
        case .initial:
            emptyView.isHidden = true
            newAnalysisView.isHidden = false
            startHereView.isHidden = true
            
        case .empty:
            /// AnalyzeHistoryEmptyCell added to show empty state
            //emptyView.isHidden = false
            newAnalysisView.isHidden = false
            startHereView.isHidden = false
            
        case .selection:
            emptyView.isHidden = true
            newAnalysisView.isHidden = true
            startHereView.isHidden = true
        }
    }
}
