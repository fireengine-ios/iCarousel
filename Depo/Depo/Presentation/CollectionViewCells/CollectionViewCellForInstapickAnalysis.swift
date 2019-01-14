//
//  CollectionViewCellForInstapickAnalysis.swift
//  Depo
//
//  Created by Andrei Novikau on 1/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstapickAnalysisCellDelegate: LBCellsDelegate {
    func onPurchase()
    func onSeeDetails(cell: UICollectionViewCell)
}

private enum InstapickAnalysisCellState {
    case noOldAnalysis
    case canNewAnalysis
    case needPurchase
    
    init(with count: InstapickAnalysisCount) {
        if count.left == 0 {
            self = .needPurchase
        } else if count.left == count.total {
            self = .noOldAnalysis
        } else {
            self = .canNewAnalysis
        }
    }
}

final class CollectionViewCellForInstapickAnalysis: BaseCollectionViewCell {
    
    @IBOutlet weak var borderView: UIView! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var shadowView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.3
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet weak var analyzeLabel: UILabel! {
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
    
    @IBOutlet weak var purchaseView: UIView!
    
    @IBOutlet weak var purchaseBackImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.image = UIImage(named: "purchase_back")
        }
    }
    
    @IBOutlet weak var purchaseButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.purchase, for: .normal)
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.layer.borderColor = UIColor.white.cgColor
            newValue.layer.borderWidth = 1
            newValue.backgroundColor = .clear
            newValue.tintColor = .white
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet weak var seeDetailsView: UIView!
    
    @IBOutlet weak var seeDetailsButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.seeDetails, for: .normal)
            newValue.tintColor = UIColor.lrTealishTwo
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
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        isHiddenContent = true
        
        contentView.backgroundColor = .white
    }
    
    func setup(with count: InstapickAnalysisCount) {
        let countText = String(format: TextConstants.analyzeHistoryAnalyzeCount, count.left, count.total)
        countLabel.text = countText
        
        let state = InstapickAnalysisCellState(with: count)
        switch state {
        case .noOldAnalysis, .canNewAnalysis:
            countLabel.textColor = ColorConstants.textGrayColor
            purchaseView.isHidden = true

        case .needPurchase:
            countLabel.textColor = ColorConstants.darkRed
            purchaseView.isHidden = false
        }
        
        isHiddenContent = false
    }
    
    // MARK: - Actions
    
    @IBAction private func onPurchasePressed(_ sender: UIButton) {
        (delegate as? InstapickAnalysisCellDelegate)?.onPurchase()
    }
    
    @IBAction private func onSeeDetailsPressed(_ sender: UIButton) {
        (delegate as? InstapickAnalysisCellDelegate)?.onSeeDetails(cell: self)
    }
}
