//
//  AutoSyncSwitcherTableViewCell.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class AutoSyncSwitcherTableViewCell: AutoSyncTableViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = .black
            newValue.font = .TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaBolFont(size: 14)
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet weak var switcher: CustomSwitch!
    
    private weak var delegate: AutoSyncCellDelegate?
    private var model: AutoSyncHeaderModel?
    
    //MARK: -
    
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?) {
        self.delegate = delegate
        self.model = model as? AutoSyncHeaderModel
        
        guard let model = self.model else {
            return
        }
        
        titleLabel.text = model.headerType.title
        switcher.isOn = model.isSelected
    }

    func didSelect() { }
    
    @IBAction private func onSwitcherValueChanged() {
        guard let model = model else {
            return
        }
        
        model.isSelected = switcher.isOn
        delegate?.didChange(model: model)
    }
}
