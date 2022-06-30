//
//  AutoSyncAlbumTableViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 3/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AutoSyncAlbumTableViewCell: AutoSyncTableViewCell {

    @IBOutlet private weak var checkBox: AutoSyncCheckBox!

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    @IBOutlet private weak var leftOffset: NSLayoutConstraint! //24 55
    
    private weak var delegate: AutoSyncCellDelegate?
    private var model: AutoSyncAlbumModel?

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
        backgroundColor = AppColor.primaryBackground.color
    }
    
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?) {
        self.model = model as? AutoSyncAlbumModel
        self.delegate = delegate
        
        guard let model = self.model else {
            return
        }
        
        titleLabel.text = model.album.name
        checkBox.setup(isSelected: model.album.isSelected,
                       isAllChecked: model.isAllChecked)

        accessibilityLabel = model.album.name
        updateAccessibilityTraits()
        
        leftOffset.constant = model.album.isMainAlbum ? 24 : 55
        
        contentView.alpha = model.isEnabled ? 1 : 0.5
    }
    
    func didSelect() { }
    
    @IBAction private func toogle() {
        guard let model = model, model.isEnabled else {
            return
        }
        
        if model.album.isMainAlbum {
            model.isAllChecked.toggle()
        } else {
            model.album.isSelected.toggle()
        }
        
        checkBox.setup(isSelected: model.album.isSelected,
                       isAllChecked: model.isAllChecked)
        updateAccessibilityTraits()

        delegate?.didChange(model: model)
    }

    override func accessibilityActivate() -> Bool {
        toogle()
        return true
    }

    private func updateAccessibilityTraits() {
        guard let model = model else { return }

        var traits: UIAccessibilityTraits = .button
        if !model.isEnabled {
            traits.insert(.notEnabled)
        }
        
        if model.album.isSelected || model.isAllChecked {
            traits.insert(.selected)
        }

        accessibilityTraits = traits
    }
}
