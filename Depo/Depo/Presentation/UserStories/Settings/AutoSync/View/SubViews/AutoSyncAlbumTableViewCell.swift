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
            newValue.textColor = ColorConstants.billoGray
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 18)
        }
    }
    @IBOutlet private weak var leftOffset: NSLayoutConstraint! //24 55
    
    private weak var delegate: AutoSyncCellDelegate?
    private var model: AutoSyncAlbumModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
    }
    
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?) {
        self.model = model as? AutoSyncAlbumModel
        self.delegate = delegate
        
        guard let model = self.model else {
            return
        }
        
        titleLabel.text = model.album.name
        checkBox.setup(isEnabled: model.isEnabled,
                       isSelected: model.album.isSelected,
                       isAllChecked: model.isAllChecked)
        
        leftOffset.constant = model.album.isMainAlbum ? 24 : 55
        
        contentView.alpha = model.isEnabled ? 1 : 0.5
    }
    
    func didSelect() {
        toogle()
    }
    
    private func toogle() {
        guard let model = model, model.isEnabled else {
            return
        }
        
        if model.album.isMainAlbum {
            model.isAllChecked.toggle()
        } else {
            model.album.isSelected.toggle()
        }
        
        checkBox.setup(isEnabled: model.isEnabled,
                       isSelected: model.album.isSelected,
                       isAllChecked: model.isAllChecked)
        delegate?.didChange(model: model)
    }
}
