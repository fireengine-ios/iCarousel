//
//  StorageCard.swift
//  Depo
//
//  Created by Oleg on 24.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StorageCard: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTileLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var bacgroundView: UIView!
    var operationType: OperationType?
    
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.textColor = ColorConstants.whiteColor
        
        subTileLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        subTileLabel.textColor = ColorConstants.whiteColor
            
        bacgroundView.clipsToBounds = true
    }
    
    @IBAction func onBottomButton(){
        
    }
    
    @IBAction func onCloseButton(){
        if let type = operationType{
            CardsManager.default.stopOperationWithType(type: type)
        }
    }
    
    func configurateWithType(viewType: OperationType){
        operationType = viewType
        
        switch viewType {
        case .freeAppSpaceCloudWarning:
            setGradient(colorTop: ColorConstants.orangeGradientStart, colorBottom: ColorConstants.orangeGradientEnd)
            iconView.image = UIImage(named: "CardIconLamp")
            
            titleLabel.text = TextConstants.homeStorageCardCloudTitle
            subTileLabel.text = TextConstants.homeStorageCardCloudSubTitle
            
            bottomButton.setTitle(TextConstants.homeStorageCardCloudBottomButtonTitle, for: .normal)
            bottomButton.setTitleColor(ColorConstants.orangeGradientEnd, for: .normal)
            break
        case .emptyStorage:
            setGradient(colorTop: ColorConstants.greenGradientStart, colorBottom: ColorConstants.greenGradientEnd)
            iconView.image = UIImage(named: "CardIconFolder")
            
            titleLabel.text = TextConstants.homeStorageCardEmptyTitle
            subTileLabel.text = TextConstants.homeStorageCardEmptySubTitle
            
            bottomButton.setTitle(TextConstants.homeStorageCardEmptyBottomButtonTitle, for: .normal)
            bottomButton.setTitleColor(ColorConstants.greenGradientEnd, for: .normal)
            break
        case .freeAppSpaceLocalWarning:
            setGradient(colorTop: ColorConstants.redGradientStart, colorBottom: ColorConstants.redGradientEnd)
            iconView.image = UIImage(named: "CardIconLamp")
            
            titleLabel.text = TextConstants.homeStorageCardLocalTitle
            subTileLabel.text = TextConstants.homeStorageCardLocalSubTitle
            
            bottomButton.setTitle(TextConstants.homeStorageCardLocalBottomButtonTitle, for: .normal)
            bottomButton.setTitleColor(ColorConstants.redGradientEnd, for: .normal)
            break
        default:
            
            return
        }
        
    } 
    
    func setGradient(colorTop: UIColor, colorBottom: UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: bacgroundView.frame.size.width, height: bacgroundView.frame.size.height)
        bacgroundView.layer.insertSublayer(gradient, at: 0)
    }

}
