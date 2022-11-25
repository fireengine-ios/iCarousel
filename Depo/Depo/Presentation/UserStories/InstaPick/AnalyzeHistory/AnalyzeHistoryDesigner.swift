//
//  AnalyzeHistoryDesigner.swift
//  Depo
//
//  Created by Andrei Novikau on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AnalyzeHistoryDesigner: NSObject {    
    @IBOutlet private weak var emptyTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryEmptyTitle
            newValue.textColor = ColorConstants.darkText
            newValue.font = .appFont(.regular, size: 18)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var emptySubtitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryEmptySubtitle
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = .appFont(.regular, size: 16)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var newAnalyseView: UIView! {
        willSet {
            let gradientView = TransparentGradientView(style: .vertical, mainColor: AppColor.primaryBackground.color)
            gradientView.frame = newValue.bounds
            newValue.addSubview(gradientView)
            newValue.sendSubviewToBack(gradientView)
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    @IBOutlet private weak var newAnalysisButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.analyzeHistoryAnalyseButton, for: .normal)
        }
    }
    
    @IBOutlet private weak var startLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryStartHereTitle
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = .appFont(.regular, size: 14)
            newValue.textAlignment = .center
            newValue.numberOfLines = 0
        }
    }
}
