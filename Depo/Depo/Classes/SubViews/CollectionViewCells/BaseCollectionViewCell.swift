//
//  BaseCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 26.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol LBCellsDelegate: class {
    func onLongPress(cell: UICollectionViewCell)
}

class BaseCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate, CollectionViewCellDataProtocol {
    
    internal weak var delegate: LBCellsDelegate?
    var isCellSelected: Bool            = false
    var isCellSelectionEnabled: Bool    = false
    
    var isAlreadyConfigured             = false
    
    static let durationOfSelection : Double = 0.5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        lpgr.minimumPressDuration = BaseCollectionViewCell.durationOfSelection
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        guard let  d = delegate else{
            return
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerState.began){
            setSelection(isSelectionActive: true, isSelected: true)
            d.onLongPress(cell: self)
        }
        
//        if (gestureRecognizer.state == UIGestureRecognizerState.cancelled){
//            animateSelection(durationOfAnimation: BaseCollectionViewCell.durationOfSelection, selection: false)
//        }
        
//        if (gestureRecognizer.state != UIGestureRecognizerState.ended){
//            return
//        }
//        
//        d.onLongPress(cell: self)
        
    }
    
    func setDelegateObject(delegateObject: LBCellsDelegate){
        self.delegate = delegateObject
    }
    
    
    func confireWithWrapperd(wrappedObj: BaseDataSourceItem){
        
    }
    
    func setImage(image: UIImage?){
        
    }
    
    func setImage(with pathForItem: PathForItem) {
        
    }
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool){
        
    }
    
    func updating(){
        isAlreadyConfigured = false
    }
}
