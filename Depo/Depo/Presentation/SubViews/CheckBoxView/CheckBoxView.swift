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
    func openAutoSyncSettings()
}

final class CheckBoxView: UIView, NibInit {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.showOnlySyncedItemsText
            newValue.textColor = ColorConstants.lightText
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    @IBOutlet private weak var checkBoxButton: UIButton!
    @IBOutlet private weak var autoSyncSettingsButton: UIButton! {
        willSet {
            newValue.tintColor = .lrTealishTwo
            newValue.setTitle(TextConstants.photosVideosAutoSyncSettings, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 13)
        }
    }
    
    weak var delegate: CheckBoxViewDelegate?
    
    var isCheck = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkBoxButton.isSelected = isCheck
    }

    @IBAction private func onCheckBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isCheck = sender.isSelected
        delegate?.checkBoxViewDidChangeValue(isCheck)
    }
    
    @IBAction private func onOpenAutoSyncSettings(_ sender: UIButton) {
        delegate?.openAutoSyncSettings()
    }
}
