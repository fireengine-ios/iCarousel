//
//  InstaPickCard.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 1/9/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickCard: BaseCardView {
    
    private enum InstaPick {
        enum CardType {
            case trial
            case usedBefore
            case noUsedBefore
            case noAnalysis
        }
        
        static let isUsedField  = "isEverUsed"
        static let isFreeField  = "isFree"
        static let leftField    = "remaining"
        static let totalField   = "total"
        
        static let usedBeforeIcon = UIImage(named: "instaPickLikesRed")
        static let defaultIcon = UIImage(named: "instaPickLikesWhite")
        
        static let regFontText = "Insta"
    }

    //IBOutlets
    @IBOutlet private weak var containerStackView: UIStackView!
    @IBOutlet private weak var gradientView: RadialGradientableView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var dividerLineView: UIView!
    
    var analysisLeft: Int = 0
    var totalCount: Int = 0
    var isUsedBefore: Bool = true
    var isFree: Bool = false

    private lazy var instapickRoutingService = InstaPickRoutingService()
    
    private var cardType: InstaPick.CardType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRecognizer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRecognizer()
    }
    
    private func setupRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onBottomButtonTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    //override
    override func configurateView() {
        super.configurateView()
        
        canSwipe = true

        detailLabel.font = .appFont(.light, size: 14)
        
        bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
        bottomButton.titleLabel?.font = .appFont(.bold, size: 14)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = containerStackView.frame.height
        if calculatedH != height {
            calculatedH = height
        }
    }

    private func configurateCard() {
        chooseType()

        guard let type = cardType else { return }
        switch type {
        case .usedBefore:
            setupTitleLabel(with: TextConstants.instaPickUsedBeforeTitleLabel, textColor: AppColor.label.color, textFont: .appFont(.medium, size: 16))
            
            gradientView.isNeedGradient = false
            dividerLineView.isHidden = false
            
            //closeButton.setImage(UIImage(named: "iconCancelBorder"), for: .normal)
            closeButton.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
            closeButton.tintColor = AppColor.label.color
            closeButton.accessibilityLabel = TextConstants.accessibilityClose
            
            detailLabel.textColor = AppColor.label.color
            detailLabel.text = TextConstants.instaPickUsedBeforeDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonHasAnalysis, for: .normal)
            
            imageView.image = InstaPick.usedBeforeIcon
            imageView.isHidden = true
            
        case .noUsedBefore:
            setupTitleLabel(with: TextConstants.instaPickNoUsedBeforeTitleLabel, textColor: AppColor.label.color, textFont: .appFont(.medium, size: 16))
            
            gradientView.isNeedGradient = true
            dividerLineView.isHidden = true

            closeButton.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
            closeButton.tintColor = AppColor.label.color
            closeButton.accessibilityLabel = TextConstants.accessibilityClose

            detailLabel.textColor = AppColor.label.color
            detailLabel.text = TextConstants.instaPickNoUsedBeforeDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonHasAnalysis, for: .normal)
            
            imageView.image = InstaPick.defaultIcon
            imageView.isHidden = true
            
        case .noAnalysis:
            setupTitleLabel(with: TextConstants.instaPickNoAnalysisTitleLabel, textColor: AppColor.label.color, textFont: .appFont(.medium, size: 16))
            
            gradientView.isNeedGradient = true
            dividerLineView.isHidden = true

            closeButton.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
            closeButton.tintColor = AppColor.label.color
            closeButton.accessibilityLabel = TextConstants.accessibilityClose

            detailLabel.textColor = AppColor.label.color
            detailLabel.text = TextConstants.instaPickNoAnalysisDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonNoAnalysis, for: .normal)
            
            imageView.image = InstaPick.defaultIcon
            imageView.isHidden = true
        case .trial:
            setupTitleLabel(with: TextConstants.instaPickFreeTrialTitleLabel, textColor: AppColor.label.color, textFont: .appFont(.medium, size: 16))
            
            gradientView.isNeedGradient = true
            dividerLineView.isHidden = true
            
            closeButton.setImage(Image.iconCancelBorder.image.withRenderingMode(.alwaysTemplate), for: .normal)
            closeButton.tintColor = AppColor.label.color
            closeButton.accessibilityLabel = TextConstants.accessibilityClose
            
            detailLabel.textColor = AppColor.label.color
            detailLabel.text = TextConstants.instaPickFreeTrialDetailLabel
            
            bottomButton.setTitle(TextConstants.instaPickButtonHasAnalysis, for: .normal)
            
            imageView.image = InstaPick.defaultIcon
            imageView.isHidden = true
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        guard
            let isUsedBefore: Bool = object?.details?[InstaPick.isUsedField].bool,
            let isFree: Bool = object?.details?[InstaPick.isFreeField].bool,
            let analysisLeft: Int = object?.details?[InstaPick.leftField].int,
            let totalCount: Int = object?.details?[InstaPick.totalField].int
        else {
            return
        }
        
        self.isUsedBefore = isUsedBefore
        self.isFree = isFree
        self.analysisLeft = analysisLeft
        self.totalCount = totalCount
        
        configurateCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .instaPick)
    }
    
    //MARK: - Utility Methods(private)
    private func setupTitleLabel(with text: String, textColor: UIColor, textFont: UIFont) {
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font : textFont,
            .foregroundColor : textColor,
            .kern: 0.29
            ])
        
        let range = NSString(string: text).range(of: InstaPick.regFontText, options: String.CompareOptions.caseInsensitive)
        attributedString.addAttribute(.font, value: textFont,
                                      range: range)
        titleLabel.attributedText = attributedString
    }
    
    private func chooseType() {
        let type: InstaPick.CardType
        if isFree {
            type = .trial
        } else if analysisLeft == 0 {
            type = .noAnalysis
        } else if !isUsedBefore {
            type = .noUsedBefore
        } else  {
            type = .usedBefore
        }
        cardType = type
    }
    
    private func openInstaPickHistory() {
        let router = RouterVC()
        
        let controller = router.analyzesHistoryController()
        router.pushViewControllertoTableViewNavBar(viewController: controller)
    }
    
    //MARK: - Utility Methods(public)
    func isNeedReloadWithNew(status: InstapickAnalyzesCount) -> Bool {
        let newCardType: InstaPick.CardType
        
        if status.isFree {
             newCardType = .trial
        } else if status.left == 0 {
            isUsedBefore = true
            newCardType = .noAnalysis
        } else if status.used > 0 || isUsedBefore {
            isUsedBefore = true
            newCardType = .usedBefore
        } else {
            newCardType = .noUsedBefore
        }

        self.analysisLeft = status.left
        self.totalCount = status.total
        self.isFree = status.isFree
        
        let isNeedLoad = newCardType != cardType
        if isNeedLoad {
            configurateCard()
            layoutIfNeeded() /// need to calculate height of card
        }
        
        return isNeedLoad
    }
    
    //MARK: - Actions
    @IBAction private func onCloseTap(_ sender: Any) {
        deleteCard()
    }
    
    @IBAction private func onBottomButtonTap(_ sender: Any) {
        guard let cardType = cardType else { return }

        switch cardType {
        case .noAnalysis:
            InstaPickRoutingService.openPremium()
        case .trial, .noUsedBefore, .usedBefore:
            openInstaPickHistory()
        }
    }
}
