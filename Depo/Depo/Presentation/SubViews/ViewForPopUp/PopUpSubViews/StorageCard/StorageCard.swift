//
//  StorageCard.swift
//  Depo
//
//  Created by Oleg on 24.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StorageCard: BaseCardView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTileLabel: UILabel!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bigButton1: UIButton!
    @IBOutlet weak var bigButton2: UIButton!
    
    var operationType: OperationType?
    
    private var gradient: CAGradientLayer?
    
    override func configurateView() {
        super.configurateView()
        
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        titleLabel.textColor = ColorConstants.whiteColor
        
        subTileLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        subTileLabel.textColor = ColorConstants.whiteColor
            
        backgroundView.clipsToBounds = true
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if self.layer == layer {
            gradient?.frame = backgroundView.bounds
        } 
    }
    
    @IBAction func onBottomButton() {
        if let operationType = operationType {
            let router = RouterVC()
            switch operationType {
            case .freeAppSpaceCloudWarning:
                let controller = router.packages
                router.pushViewController(viewController: controller)
                break
            case .emptyStorage:
                let controller = router.uploadPhotos()
                let navigation = NavigationController(rootViewController: controller)
                navigation.navigationBar.isHidden = false
                router.presentViewController(controller: navigation)
                break
            case .freeAppSpaceLocalWarning:
                let controller = router.freeAppSpace()
                router.pushViewController(viewController: controller)
                break
            default:
                return
            }
        }
    }
    @IBAction func onBigButton() {
        if let operationType = operationType, operationType == .freeAppSpaceLocalWarning {
            onBottomButton()
        }
    }
    
    @IBAction func onCloseButton() {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        if let type = operationType {
            CardsManager.default.stopOperationWithType(type: type)
        }
    }
    
    func configurateWithType(viewType: OperationType) {
        operationType = viewType
        
        switch viewType {
        case .freeAppSpaceCloudWarning:
            setGradient(colorTop: ColorConstants.orangeGradientStart, colorBottom: ColorConstants.orangeGradientEnd)
            iconView.image = UIImage(named: "CardIconLamp")
            
            titleLabel.text = TextConstants.homeStorageCardCloudTitle
            
            bottomButton.setTitle(TextConstants.homeStorageCardCloudBottomButtonTitle, for: .normal)
            bottomButton.setTitleColor(ColorConstants.orangeGradientEnd, for: .normal)
            
            subTileLabel.text = ""
            
        case .emptyStorage:
            setGradient(colorTop: ColorConstants.greenGradientStart, colorBottom: ColorConstants.greenGradientEnd)
            iconView.image = UIImage(named: "CardIconFolder")
            
            titleLabel.text = TextConstants.homeStorageCardEmptyTitle
            subTileLabel.text = TextConstants.homeStorageCardEmptySubTitle
            
            bottomButton.setTitle(TextConstants.homeStorageCardEmptyBottomButtonTitle, for: .normal)
            bottomButton.setTitleColor(ColorConstants.greenGradientEnd, for: .normal)
            
        case .freeAppSpaceLocalWarning:
            setGradient(colorTop: ColorConstants.redGradientStart, colorBottom: ColorConstants.redGradientEnd)
            iconView.image = UIImage(named: "CardIconLamp")
            
            titleLabel.text = TextConstants.homeStorageCardLocalTitle
            let percentDouble = 1 - Device.getFreeDiskSpaceInPercent
            
            let percent = Int(round(percentDouble * 100))
            subTileLabel.text = String(format: TextConstants.homeStorageCardLocalSubTitle, percent)
            
            bottomButton.setTitle(TextConstants.homeStorageCardLocalBottomButtonTitle, for: .normal)
            bottomButton.setTitleColor(ColorConstants.redGradientEnd, for: .normal)
            
        default:
            break
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        
        configurateByResponseObject()
    }
    
    func configurateByResponseObject() {
        if operationType == .freeAppSpaceCloudWarning, let percent = cardObject?.details?["usage-percentage"].int {
            subTileLabel.text = String(format: TextConstants.homeStorageCardCloudSubTitle, percent)
        }
    }
    
    func setGradient(colorTop: UIColor, colorBottom: UIColor) {
        let gradient = CAGradientLayer()
        gradient.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = backgroundView.frame
        backgroundView.layer.insertSublayer(gradient, at: 0)
        self.gradient = gradient
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let backgroundViewHeight = backgroundView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        
        let bottomSpace : CGFloat = 0.0
        let h = backgroundViewHeight + bottomButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }

}
