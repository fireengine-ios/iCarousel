//
//  CellAppearanceModel.swift
//  Depo
//
//  Created by Aleksandr on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct CellAppearanceModel {
    let size: CGSize
    let insetsEdge: UIEdgeInsets
    
    let minimumSectionLineSpacing: CGFloat
    let minimumInteritemSpacingSection: CGFloat
    
    let headerSize: CGSize
    
    let barColor: UIColor
    
    let appearanceType: BasicCollectionControllerAppearanceConfig.collectionAppearanceTypes
}
