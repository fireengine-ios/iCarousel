//
//  AutoSyncInformTableViewCell.swift
//  Depo
//
//  Created by Oleg on 16.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol AutoSyncInformTableViewCellCheckBoxStateProtocol: class {
    func checkBoxChangedState(state: Bool, model: AutoSyncModel, cell: AutoSyncInformTableViewCell)
}

class AutoSyncInformTableViewCell: UITableViewCell {
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var checkBoxButton: UIButton!
    
    weak var stateDelegate: AutoSyncInformTableViewCellCheckBoxStateProtocol?
    
    var model: AutoSyncModel?
    
    var descriptionLableText: String? {
        didSet {
            if descriptionLableText! == "" {
                return
            }
            descriptionLabel.text = descriptionLableText!
            titleLabelTopConstraint.constant = 15
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        
        titleLabel.textColor = ColorConstants.whiteColor
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        
        descriptionLabel.textColor = ColorConstants.whiteColor
        descriptionLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
    }
    
    func configurateCellWith(model: AutoSyncModel) {
        self.model = model
        descriptionLableText = model.subTitleString
        titleLabel.text = model.titleString
        
        separatorView.isHidden = model.titleString.count == 0
        
        
        checkBoxButton.isSelected = model.isSelected
        configureCellsItemsWithModel()
    }
    
    func setColors(isFromSettings: Bool) {
        titleLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        descriptionLabel.textColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
        separatorView.backgroundColor = isFromSettings ? ColorConstants.textGrayColor : ColorConstants.whiteColor
    }
    
    @IBAction func checkBoxButtonHandler(_ sender: Any) {
        checkBoxButton.isSelected = !checkBoxButton.isSelected
        let newModel = AutoSyncModel(model: model!, selected: checkBoxButton.isSelected)
        model = newModel
        configureCellsItemsWithModel()
        stateDelegate?.checkBoxChangedState(state: checkBoxButton.isSelected,
                                            model: newModel, cell: self)
    }
    
    private func configureCellsItemsWithModel() {
        let alpha = CGFloat(model!.isSelected ? 1.0 : 0.6)
        configureCellsItemsTransparency(alpha: alpha)
    }
    
    private func configureCellsItemsTransparency(alpha: CGFloat) {
        titleLabel.alpha = alpha
        descriptionLabel.alpha = alpha
    }
 }
