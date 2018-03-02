//
//  AutoSyncSettingsTableViewCell.swift
//  Depo_LifeTech
//
//  Created by Konstantin on 2/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum AutoSyncType {
    case image
    case video
}


class AutoSyncSettingsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var syncItemTypeName: UILabel!
    @IBOutlet private weak var selectLabel: UILabel!
    
    @IBOutlet private var optionsViews: [AutoSyncSettingsOptionView]!
    
    private var isFullHeight: Bool = false
    
    private var autoSyncType: AutoSyncType = .image
    private let options: [AutoSyncSettingsOption] = [.never, .wifiOnly, .wifiAndCellular]
    private var selectedOptionIndex: Int = 0
    
    var cellHeight: Float {
        return isFullHeight ? 228 : 57
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()

        for (index, view) in optionsViews.enumerated() {
            view.configure(with: options[index], isSelected: (index == selectedOptionIndex) ? true : false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func configurateCellWith(model: AutoSyncModel) {
        
    }
    
}
