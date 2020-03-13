//
//  AutoSyncHeaderTableViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 3/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class AutoSyncHeaderTableViewCell: AutoSyncTableViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = .black
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
        }
    }
    
    @IBOutlet private weak var optionLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = ColorConstants.billoGray
            newValue.font = UIFont.TurkcellSaturaFont(size: 18)
        }
    }
    
    @IBOutlet private weak var dropDownArrow: UIImageView!
    @IBOutlet private weak var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.profileGrayColor
        }
    }
    
    private weak var delegate: AutoSyncCellDelegate?
    private var model: AutoSyncHeaderModel?

    //MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .white
    }
    
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?) {
        self.model = model as? AutoSyncHeaderModel
        self.delegate = delegate

        guard let model = model as? AutoSyncHeaderModel else {
            return
        }
        
        titleLabel.text = model.headerType.title
        optionLabel.text = model.headerType.subtitle(setting: model.setting)
        setupArrow(isSelected: model.isSelected, animated: false)
    }
    
    func didSelect() {
        toggle()
    }
    
    private func setupArrow(isSelected: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? NumericConstants.animationDuration : 0) {
            self.dropDownArrow.transform = isSelected ? CGAffineTransform(rotationAngle: -.pi) : .identity
        }
    }
    
    private func toggle() {
        guard let model = model else {
            return
        }
        
        model.isSelected.toggle()
        setupArrow(isSelected: model.isSelected, animated: true)

        delegate?.didChange(model: model)
    }
}
