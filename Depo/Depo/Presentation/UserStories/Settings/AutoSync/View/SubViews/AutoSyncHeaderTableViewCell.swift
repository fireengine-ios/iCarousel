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
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    
    @IBOutlet private weak var optionLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.lightText.color
            newValue.font = .appFont(.regular, size: 14)
        }
    }
    
    @IBOutlet private weak var descriptionLabel: InsetsLabel! {
        willSet {
            newValue.text = ""
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 14)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.insets = .init(top: 0, left: 0, bottom: 15, right: 0)
        }
    }
    
    @IBOutlet private weak var dropDownArrow: UIImageView!
    
    private weak var delegate: AutoSyncCellDelegate?
    private var model: AutoSyncHeaderModel?
    
    var isExpanded: Bool {
        model?.isSelected ?? false
    }

    //MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppColor.primaryBackground.color
    }
    
    func setup(with model: AutoSyncModel, delegate: AutoSyncCellDelegate?) {
        self.model = model as? AutoSyncHeaderModel
        self.delegate = delegate

        guard let model = model as? AutoSyncHeaderModel else {
            return
        }
        
        titleLabel.text = model.headerType.title
        setupSubtitle()
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
    
    private func setupSubtitle() {
        guard let model = model else {
            return
        }
        
        let subtitle = model.headerType.subtitle(setting: model.setting)
        switch model.headerType {
        case .albums:
            optionLabel.text = ""
            descriptionLabel.text = subtitle
        default:
            optionLabel.text = subtitle
            descriptionLabel.text = ""
        }
    }
    
    private func toggle() {
        guard let model = model else {
            return
        }
        
        model.isSelected.toggle()
        setupSubtitle()
        setupArrow(isSelected: model.isSelected, animated: true)

        delegate?.didChange(model: model)
    }
}
