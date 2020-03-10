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
        checkBox.isSelected = model.album.isSelected
        checkBox.isEnabled = model.isEnabled
        
        contentView.alpha = model.isEnabled ? 1 : 0.5
    }
    
    func didSelect() {
        toogle()
    }
    
    private func toogle() {
        guard checkBox.isEnabled, let model = model else {
            return
        }
        
        model.album.isSelected.toggle()
        checkBox.isSelected = model.album.isSelected
        delegate?.didChange(model: model)
    }
}
