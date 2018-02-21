//
//  SuggestionTableViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 20.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class SuggestionTableViewCell: UITableViewCell {

    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        nameLabel.textColor = .white
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func configure(withSuggest suggest: SuggestionObject?) {
        guard let suggest = suggest else {
            return
        }
        
        typeImageView.image = suggest.type?.image
        typeImageView.isHidden = typeImageView.image == nil ? true : false
        
        if let highlightedText = suggest.highlightedText {
            nameLabel.attributedText = highlightedText
        } else if let text = suggest.text {
            nameLabel.text = text
        }
    }

    func configure(withRecent recent: RecentSearchesObject?) {
        guard let recent = recent else {
            return
        }
        
        typeImageView.image = recent.type?.image
        typeImageView.isHidden = typeImageView.image == nil ? true : false
        nameLabel.text = recent.text ?? ""
    }
    
}
