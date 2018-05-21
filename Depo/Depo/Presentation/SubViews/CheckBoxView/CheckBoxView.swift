//
//  CheckBoxView.swift
//  Depo
//
//  Created by Andrei Novikau on 18/05/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol CheckBoxViewDelegate: class {
    func checkBoxViewDidChangeValue(_ value: Bool)
}

final class CheckBoxView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var checkBoxButton: UIButton!
    
    weak var delegate: CheckBoxViewDelegate?
    
    var isCheck = false
    var title = TextConstants.showOnlySyncedItemsText
    
    class func initFromXib() -> CheckBoxView {
        let view = UINib(nibName: "CheckBoxView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CheckBoxView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkBoxButton.isSelected = isCheck
        titleLabel.textColor = ColorConstants.lightText
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        titleLabel.text = title
    }

    @IBAction private func onCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isCheck = sender.isSelected
        delegate?.checkBoxViewDidChangeValue(isCheck)
    }
    
}
