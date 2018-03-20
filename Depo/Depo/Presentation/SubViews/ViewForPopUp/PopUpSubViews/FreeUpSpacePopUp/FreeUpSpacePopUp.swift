//
//  FreeUpSpacePopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 02.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class FreeUpSpacePopUp: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bigTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var freeAppSpaceButton: CircleYellowButton!
    
    private var operation: OperationType?
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        titleLabel.textColor = ColorConstants.textGrayColor
        
        bigTitleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        bigTitleLabel.textColor = ColorConstants.textGrayColor
        
        freeAppSpaceButton.setTitle(TextConstants.freeAppSpacePopUpButtonTitle, for: .normal)
    }
    
    override func viewDeletedBySwipe() {
        onCancelButton()
    }
    
    @IBAction func onCancelButton() {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.manuallyDeleteCardsByType(type: operation ?? .freeAppSpace)
    }
    
    @IBAction func onFreeAppSpaceButton() {
        RouterVC().showFreeAppSpace()
    }
    
    func configurateWithType(viewType: OperationType) {
        operation = viewType
        
        switch viewType {
        case .freeAppSpace:
            titleLabel.text = TextConstants.freeAppSpacePopUpTextNormal
            bigTitleLabel.isHidden = true
            titleLabel.isHidden = false
            imageView.isHidden = false
        default:
            return
        }
    }
    
}
