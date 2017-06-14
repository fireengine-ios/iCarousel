//
//  GSMUserInputCell.swift
//  Depo
//
//  Created by Aleksandr on 6/12/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol GSMCodeCellDelegate {
    func codeViewGotTapped()
}

class GSMUserInputCell: BaseUserInputCellView {

    @IBOutlet weak var gsmCountryCodeLabel: UILabel!
    @IBOutlet weak var gsmCodeContainerView: UIView!
    
    var delegate: GSMCodeCellDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gsmCodeContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GSMUserInputCell.codeViewTouched)))
    }
    
    override func setupCell(withTitle title: String, inputText text: String, cellType type: CellTypes) {
        self.titleLabel.text = title
//        self.gsmCountryCodeLabel.text = "+376"
    }
    
    func setupGSMCode(code: String) {
        self.gsmCountryCodeLabel.text = code
        
    }
    
    func codeViewTouched() {
        debugPrint("TAP TAP TAP")
        self.delegate?.codeViewGotTapped()
    }
    
//    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        <#code#>
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.events?.viewTapped()
//    }
}
