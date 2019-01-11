//
//  InstaPickCard.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickCard: BaseView {
    
    private enum InstaPick {
        enum CardType {
            case usedBefore
            case noUsedBefore
            case noAnalysis
        }
        
        static let isUsedField = "isUsed"
        static let leftField = "left"
        static let totalField = "total"
        
        static let usedBeforeIcon = UIImage(named: "instaPickLikesRed")
        static let defaultIcon = UIImage(named: "instaPickLikesWhite")
        
        static let regFontText = "Insta"
    }

    //IBOutlets
    @IBOutlet private weak var gradientView: RadialGradientView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    
    var analysisLeft: Int = 0
    var totalCount: Int = 0
    var isUsedBefore: Bool = true
    
    private var cardType: InstaPick.CardType?
    //override
    override func configurateView() {
        super.configurateView()
        
        canSwipe = true

        detailLabel.font = UIFont.TurkcellSaturaDemFont(size: 14)
        
        bottomButton.setTitleColor(UIColor.lrTealish, for: .normal)
        bottomButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
    }
    
    override func viewWillShow() {
        super.viewWillShow()
        
        chooseType()
        configurateCard()
    }
    
    private func configurateCard() {
        guard let type = cardType else { return }
        switch type {
        case .usedBefore:
            setupTitleLabel(with: TextConstants.instaPickUsedBeforeTitleLabel, textColor: ColorConstants.darkText)
            
            gradientView.isNeedGradient = false
            
            detailLabel.textColor = ColorConstants.darkText
            detailLabel.text = TextConstants.instaPickUsedBeforeDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonHasAnalysis, for: .normal)
            
            imageView.image = InstaPick.usedBeforeIcon
            
        case .noUsedBefore:
            setupTitleLabel(with: TextConstants.instaPickNoUsedBeforeTitleLabel, textColor: UIColor.white)
            
            detailLabel.textColor = UIColor.white
            detailLabel.text = TextConstants.instaPickNoUsedBeforeDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonHasAnalysis, for: .normal)
            
            imageView.image = InstaPick.defaultIcon
            
        case .noAnalysis:
            setupTitleLabel(with: TextConstants.instaPickNoAnalysisTitleLabel, textColor: UIColor.white)
            
            detailLabel.textColor = UIColor.white
            detailLabel.text = TextConstants.instaPickNoAnalysisDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonNoAnalysis, for: .normal)
            
            imageView.image = InstaPick.defaultIcon
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        guard  let isUsedBefore: Bool = object?.details?[InstaPick.isUsedField].bool,
            let analysisLeft: Int = object?.details?[InstaPick.leftField].int,
            let totalCount: Int = object?.details?[InstaPick.totalField].int else { return }
        
        self.isUsedBefore = isUsedBefore
        self.analysisLeft = analysisLeft
        self.totalCount = totalCount
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWithType(type: .instaPick)
    }
    
    //MARK: - Utility Methods(private)
    private func setupTitleLabel(with text: String, textColor: UIColor) {
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font : UIFont.TurkcellSaturaBolFont(size: 18),
            .foregroundColor : textColor,
            .kern: 0.29
            ])
        
        let range = NSString(string: text).range(of: InstaPick.regFontText, options: String.CompareOptions.caseInsensitive)
        attributedString.addAttribute(.font, value: UIFont.TurkcellSaturaRegFont(size: 18),
                                      range: range)
        titleLabel.attributedText = attributedString
    }
    
    private func chooseType() {
        let type: InstaPick.CardType
        if !isUsedBefore {
            type = .noUsedBefore
        } else if analysisLeft == 0 {
            type = .noAnalysis
        } else {
            type = .usedBefore
        }
        cardType = type
    }
    
    //MARK: - Utility Methods(public)
    func isNeedReloadWithNew(totalCount: Int, leftCount: Int) -> Bool {
        var newCardType: InstaPick.CardType = .noUsedBefore
        if leftCount == 0 {
            isUsedBefore = true
            newCardType = .noAnalysis
        } else if totalCount != leftCount {
            isUsedBefore = true
            newCardType = .usedBefore
        }

        self.analysisLeft = leftCount
        self.totalCount = totalCount
        
        return newCardType != cardType
    }
    
    //MARK: - Actions
    @IBAction private func onCloseTap(_ sender: Any) {
        deleteCard()
    }
    
    
    @IBAction private func onBottomButtonTap(_ sender: Any) {
        //TODO: add redirect for different types
        guard let cardType = cardType else { return }
        switch cardType {
        case .usedBefore:
            break
        case .noUsedBefore:
            break
        case .noAnalysis:
            break
        }
    }
}
