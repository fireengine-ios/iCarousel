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
        canSwipe = false
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
                let controller = router.packages()
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
    
    override func deleteCard() {
        super.deleteCard()
        if let type = operationType {
            CardsManager.default.stopOperationWith(type: type)
        }
    }
    
    func configurateWithType(viewType: OperationType) {
        operationType = viewType
        
        switch viewType {
        case .freeAppSpaceCloudWarning:
            titleLabel.text = TextConstants.homeStorageCardCloudTitle
            titleLabel.font = .appFont(.medium, size: 16)
            titleLabel.textColor = AppColor.label.color
            
            bottomButton.setTitle(TextConstants.homeStorageCardCloudBottomButtonTitle, for: .normal)
            bottomButton.titleLabel?.font = .appFont(.bold, size: 14)
            bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            
            subTileLabel.text = ""
            
        case .emptyStorage:
            titleLabel.text = TextConstants.homeStorageCardEmptyTitle
            titleLabel.font = .appFont(.medium, size: 16)
            titleLabel.textColor = AppColor.label.color
            subTileLabel.text = TextConstants.homeStorageCardEmptySubTitle
            subTileLabel.font = .appFont(.light, size: 14)
            subTileLabel.textColor = AppColor.label.color
            
            bottomButton.setTitle(TextConstants.homeStorageCardEmptyBottomButtonTitle, for: .normal)
            bottomButton.titleLabel?.font = .appFont(.bold, size: 14)
            bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            
        case .freeAppSpaceLocalWarning:
            titleLabel.text = TextConstants.homeStorageCardLocalTitle
            titleLabel.font = .appFont(.medium, size: 16)
            titleLabel.textColor = AppColor.label.color
            let percentDouble = 1 - Device.getFreeDiskSpaceInPercent
            
            let percent = Int(round(percentDouble * 100))
            subTileLabel.text = String(format: TextConstants.homeStorageCardLocalSubTitle, percent)
            subTileLabel.font = .appFont(.light, size: 14)
            subTileLabel.textColor = AppColor.label.color
            
            bottomButton.setTitle(TextConstants.homeStorageCardLocalBottomButtonTitle, for: .normal)
            bottomButton.titleLabel?.font = .appFont(.bold, size: 14)
            bottomButton.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            
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
        
        let backgroundViewHeight = backgroundView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        
        let bottomSpace : CGFloat = 0.0
        let h = backgroundViewHeight + bottomButton.frame.size.height + bottomSpace
        if calculatedH != h{
            calculatedH = h
            layoutIfNeeded()
        }
    }

}
