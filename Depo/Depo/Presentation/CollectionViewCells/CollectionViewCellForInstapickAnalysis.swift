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
    func onSeeDetails()
}

private enum InstapickAnalysisCellState {
    case noOldAnalysis
    case canNewAnalysis
    case needPurchase
    
    init(with count: AnalysisCount) {
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
    
    @IBOutlet weak var borderView: ShadowView!
    
    @IBOutlet weak var analyzeLabel: UILabel! {
        willSet {
            analyzeLabel.textColor = ColorConstants.textGrayColor
            analyzeLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    @IBOutlet weak var countLabel: UILabel! {
        willSet {
            countLabel.textColor = ColorConstants.textGrayColor
            countLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
            countLabel.textAlignment = .right
        }
    }
    
    @IBOutlet weak var purchaseView: UIView!
    
    @IBOutlet weak var purchaseBackImageView: UIImageView! {
        willSet {
            purchaseBackImageView.contentMode = .scaleAspectFit
            purchaseBackImageView.image = UIImage(named: "purchase_back")
        }
    }
    
    @IBOutlet weak var purchaseButton: UIButton! {
        willSet {
            purchaseButton.clipsToBounds = true
            purchaseButton.layer.borderColor = UIColor.white.cgColor
            purchaseButton.layer.borderWidth = 1
            purchaseButton.backgroundColor = .clear
            purchaseButton.tintColor = .white
            purchaseButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet weak var seeDetailsView: UIView!
    
    @IBOutlet weak var seeDetailsButton: UIButton! {
        willSet {
            seeDetailsButton.tintColor = UIColor.lrTealishTwo
            seeDetailsButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
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
    }
    
    func setup(with count: AnalysisCount) {
        countLabel.text = "\(count.left) of \(count.total)"
        
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
        (delegate as? InstapickAnalysisCellDelegate)?.onSeeDetails()
    }
}
