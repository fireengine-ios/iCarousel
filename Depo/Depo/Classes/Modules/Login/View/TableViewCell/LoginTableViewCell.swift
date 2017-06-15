//
//  LoginTableViewCell.swift
//  Depo
//
//  Created by Oleg on 08.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class LoginTableViewCell: UITableViewCell {
    
    var textInputView: TextInputView
    
    class func initFromNib() -> LoginTableViewCell{
        let nibName = String(describing: self)
        let nibs = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let view = nibs?[0] else {
            return LoginTableViewCell()
        }
        let loginTableViewCell = view as! LoginTableViewCell
        return loginTableViewCell
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.textInputView = TextInputView.viewFromNib()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.textInputView = TextInputView.viewFromNib()
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.addSubview(self.textInputView)
    }
    
    func configurateWithType(cellType: TextInputView.TextInputViewType){
        self.textInputView.configurateViewWithType(viewType: cellType)
    }
    
    func returnText() -> String {
        guard let text = textInputView.textField.text else {
            return ""
        }
        return text
    }
    
    class func cellH() -> CGFloat {
        return 86.0
    }
    
}
