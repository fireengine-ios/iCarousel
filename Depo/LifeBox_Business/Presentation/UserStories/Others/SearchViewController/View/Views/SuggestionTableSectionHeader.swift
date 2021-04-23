//
//  SuggestionTableSectionHeader.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 12/18/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

protocol SuggestionTableSectionHeaderDelegate: class {
    func onClearRecentSearchesTapped()
}

final class SuggestionTableSectionHeader: UITableViewCell {
    
    private weak var delegate: SuggestionTableSectionHeaderDelegate?
    
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = UIFont.GTAmericaStandardBoldFont(size: 18)
        titleLabel.textColor = .white
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func configureWith(category: SearchCategory, delegate: SuggestionTableSectionHeaderDelegate? = nil) {
        self.delegate = delegate
        
        switch category {
        case .suggestionHeader:
            titleLabel.text = TextConstants.searchSuggestionsTitle
            clearButton.isHidden = true
        case .recentHeader:
            titleLabel.text = TextConstants.searchRecentSearchTitle
            clearButton.isHidden = false
        default:
            titleLabel.text = ""
            clearButton.isHidden = true
        }
    }
    
    @IBAction private func onClearButtonTapped(_ sender: Any) {
        delegate?.onClearRecentSearchesTapped()
    }
    
    static func heightFor(category: SearchCategory) -> CGFloat {
        switch category {
        case .suggestionHeader:
            return 50
        case .recentHeader:
            return 64
        default:
            return 0
        }
    }
}
