//
//  FreeUpSpacePopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 02.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class FreeUpSpacePopUp: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: CircleButtonWithGrayCorner!
    @IBOutlet weak var freeAppSpaceButton: CircleYellowButton!
    
    override class func initFromNib() -> FreeUpSpacePopUp{
        if let view = super.initFromNib() as? FreeUpSpacePopUp{
            return view
        }
        return FreeUpSpacePopUp()
    }
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        titleLabel.textColor = ColorConstants.textGrayColor
        
        
        cancelButton.setTitle(TextConstants.cancel, for: .normal)
        
        freeAppSpaceButton.setTitle(TextConstants.freeAppSpacePopUpButtonTitle, for: .normal)
    }
    
    override func viewDeletedBySwipe(){
        onCancelButton()
    }
    
    @IBAction func onCancelButton(){
        WrapItemOperatonManager.default.stopOperationWithType(type: .freeAppSpace)
    }
    
    @IBAction func onFreeAppSpaceButton(){
        RouterVC().showFreeAppSpace()
    }
    
    func configurateWithType(viewType: OperationType){
        switch viewType {
        case .freeAppSpace:
            titleLabel.text = TextConstants.freeAppSpacePopUpTextNormal
            
        case .freeAppSpaceWarning:
            titleLabel.text = TextConstants.freeAppSpacePopUpTextWaring
            
        default:
            return
        }
    }
    
}
