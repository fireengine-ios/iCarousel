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

class SuggestionTableSectionHeader: UITableViewCell {
    
    enum Category: Int {
        case suggestion = 0, recent
    }
    
    private weak var delegate: SuggestionTableSectionHeaderDelegate?
    
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 15)
        titleLabel.textColor = ColorConstants.darcBlueColor
    }
    
    func configureWith(category: Category, delegate: SuggestionTableSectionHeaderDelegate? = nil) {
        self.delegate = delegate
        
        switch category {
        case .suggestion:
            titleLabel.text = TextConstants.searchSuggestionsTitle
            clearButton.isHidden = true
        case .recent:
            titleLabel.text = TextConstants.searchRecentSearchTitle
            clearButton.isHidden = false
        }
    }
    
    @IBAction private func onClearButtonTapped(_ sender: Any) {
        delegate?.onClearRecentSearchesTapped()
    }
}
