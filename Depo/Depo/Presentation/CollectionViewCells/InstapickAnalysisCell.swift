//
//  InstapickAnalysisCell.swift
//  Depo
//
//  Created by Andrei Novikau on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstapickAnalysisCellDelegate: class {
    func onPurchase()
    func onSeeDetails(cell: UICollectionViewCell)
}

private enum InstapickAnalysisCellState {
    case noOldAnalysis
    case canNewAnalysis
    case needPurchase
    
    init(with count: InstapickAnalyzesCount) {
        if count.left == 0 {
            self = .needPurchase
        } else if count.left == count.total {
            self = .noOldAnalysis
        } else {
            self = .canNewAnalysis
        }
    }
}

final class InstapickAnalysisCell: UICollectionViewCell {
    
    @IBOutlet private weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.3
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var analyzeLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.analyzeHistoryAnalyzeLeft
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    @IBOutlet weak var countLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 18)
            newValue.textAlignment = .right
        }
    }
    
    @IBOutlet private weak var purchaseView: UIView!
    
    @IBOutlet private weak var purchaseButton: InsetsButton! {
        willSet {
            newValue.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            newValue.setTitle(TextConstants.instaPickButtonNoAnalysis, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.backgroundColor = .clear
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.layer.borderColor = UIColor.white.cgColor
            newValue.layer.borderWidth = 1
        }
    }
    
    @IBOutlet private weak var seeDetailsView: UIView!
    
    @IBOutlet private weak var seeDetailsButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.analyzeHistorySeeDetails, for: .normal)
            newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    private var isHiddenContent = true {
        didSet {
            seeDetailsView.isHidden = isHiddenContent
            purchaseView.isHidden = isHiddenContent
            countLabel.isHidden = isHiddenContent
        }
    }
    
    weak var delegate: InstapickAnalysisCellDelegate?
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isHiddenContent = true
    }
    
    func setup(with count: InstapickAnalyzesCount) {
        if count.left == 0, count.total == 0 {
            isHiddenContent = true
            return
        }
        
        let countText = String(format: TextConstants.analyzeHistoryAnalyzeCount, count.left, count.total)
        countLabel.text = countText
        countLabel.isHidden = false
        
        let state = InstapickAnalysisCellState(with: count)
        switch state {
        case .noOldAnalysis, .canNewAnalysis:
            countLabel.textColor = ColorConstants.textGrayColor
            purchaseView.isHidden = true
            seeDetailsView.isHidden = false

        case .needPurchase:
            countLabel.textColor = ColorConstants.darkRed
            purchaseView.isHidden = false
            seeDetailsView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func onPurchasePressed(_ sender: UIButton) {
        delegate?.onPurchase()
    }
    
    @IBAction private func onSeeDetailsPressed(_ sender: UIButton) {
        delegate?.onSeeDetails(cell: self)
    }
}
