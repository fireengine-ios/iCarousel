//
//  SuggestionTableViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 20.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class SuggestionTableViewCell: UITableViewCell {

    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        nameLabel.textColor = .white
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func configure(with item: SuggestionObject?, recent: Bool) {
        guard let item = item else {
            return
        }
        
        typeImageView.image = item.type?.image
        typeImageView.isHidden = typeImageView.image == nil ? true : false
        
        if !recent, let highlightedText = item.highlightedText {
            nameLabel.attributedText = highlightedText
        } else if let text = item.text {
            nameLabel.text = text
        }
    }
    
}
