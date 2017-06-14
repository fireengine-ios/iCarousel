//
//  BaseUserInputCellView.swift
//  Depo
//
//  Created by Aleksandr on 6/9/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class BaseUserInputCellView: UITableViewCell {
    
    @IBOutlet weak var inputFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textInputField: UITextField!
    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textInputField.becomeFirstResponder()
        self.titleLabel.textColor = ColorConstants.whiteColor
    }
    
    func setupCell(withTitle title: String, inputText text: String, cellType type: CellTypes) {
        self.titleLabel.text = title
        self.textInputField.text = text
    }
    
    @IBAction func onShowTextButton(){
        
    }
}
