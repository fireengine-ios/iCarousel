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
            newValue.font = .appFont(.regular, size: 12.0)
            newValue.textColor = AppColor.label.color
        }
    }

    func setupLabel(question: String) {
        questionLabel.text = question
    }
}
