//
//  QuestionCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class QuestionCell: UITableViewCell {

    @IBOutlet private weak var questionLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 18)
            newValue.textColor = ColorConstants.textGrayColor.color
        }
    }

    func setupLabel(question: String) {
        questionLabel.text = question
    }
}
