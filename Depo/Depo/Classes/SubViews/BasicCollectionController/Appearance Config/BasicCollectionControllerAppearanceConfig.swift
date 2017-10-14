//
//  BasicCollectionControllerAppearanceConfig.swift
//  Depo
//
//  Created by Aleksandr on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class BasicCollectionControllerAppearanceConfig {
    static let winSize = UIScreen.main.bounds
    
    static let cellsCountInIpadsRow: CGFloat = 4
    static let cellsCountInIphoneRow: CGFloat = 2
    
    static let cellsCountInGridHeightIPhone: CGFloat = 3
    static let cellsCountInGridHeightIPad: CGFloat = 5
    
    enum collectionAppearanceTypes: Int {
        case listiPhone
        case gridiPhone
        case listiPad
        case gridiPad
    }
    
    static let cellListAppearanceModeliPhone =  CellAppearanceModel(size: CGSize(width: winSize.width - 20, height: 65),
                                                                    insetsEdge: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                                                    minimumSectionLineSpacing: 0, minimumInteritemSpacingSection: 10,
                                                                    headerSize: CGSize(width: winSize.width, height: 64),
                                                                    barColor: UIColor.white, appearanceType: .listiPhone)
    static let cellGridAppearanceModeliPhone =  CellAppearanceModel(size: CGSize(width: winSize.width/cellsCountInIphoneRow - 20, height: winSize.height/cellsCountInGridHeightIPhone),
                                                                    insetsEdge: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                                                                    minimumSectionLineSpacing: 10, minimumInteritemSpacingSection: 10,
                                                                    headerSize: CGSize(width: winSize.width, height: 65),
                                                                    barColor: UIColor.gray, appearanceType: .gridiPhone)
    static let cellGridAppearanceModeliPad = CellAppearanceModel(size: CGSize(width: winSize.width/cellsCountInIpadsRow - 20, height: winSize.height/cellsCountInGridHeightIPad),
                                                                 insetsEdge: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                                                                 minimumSectionLineSpacing: 10, minimumInteritemSpacingSection: 10,
                                                                 headerSize:  CGSize(width: winSize.width, height: 65),
                                                                 barColor: UIColor.gray, appearanceType: .gridiPad)

}
