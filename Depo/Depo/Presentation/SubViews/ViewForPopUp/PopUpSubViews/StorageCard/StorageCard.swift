//
//  StorageCard.swift
//  Depo
//
//  Created by Oleg on 24.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class StorageCard: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subTileLabel: UILabel?
    @IBOutlet weak var bottomButton: UIButton?
    @IBOutlet weak var iconView: UIImageView?
    @IBOutlet weak var bacgroundView: UIView?
    
    
    
    override func configurateView() {
        super.configurateView()
    }
    
    @IBAction func onBottomButton(){
        
    }
    
    @IBAction func onCloseButton(){
        
    }
    
    func configurateWithType(viewType: OperationType){
        switch viewType {
        case .freeAppSpaceCloudWarning:
            
            return
        case .emptyStorage:
            
            return
        case .freeAppSpaceLocalWarning:
            
            return
        default:
            
            return
        }
    }

}
