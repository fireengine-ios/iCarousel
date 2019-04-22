//
//  BaseCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 26.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol LBCellsDelegate: class {
    func canLongPress() -> Bool
    func onLongPress(cell: UICollectionViewCell)
}

class BaseCollectionViewCell: UICollectionViewCell, CollectionViewCellDataProtocol {
    internal weak var delegate: LBCellsDelegate?
    var isCellSelected: Bool = false
    var isCellSelectionEnabled: Bool = false
    
    var isAlreadyConfigured = false
    
    static let durationOfSelection: Double = 0.5
    
    private var assetId: String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let lpgr: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        lpgr.minimumPressDuration = BaseCollectionViewCell.durationOfSelection
//        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        addGestureRecognizer(lpgr)
        
        contentView.backgroundColor = ColorConstants.photoCell
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        guard let d = delegate, d.canLongPress() else {
            return
        }
        
        if (gestureRecognizer.state == UIGestureRecognizerState.began) {
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
    
    func setDelegateObject(delegateObject: LBCellsDelegate) {
        self.delegate = delegateObject
    }
    
    
    func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        
    }
    
    func setImage(image: UIImage?, animated: Bool) {

    }
    
    func setImage(with url: URL) {
        
    }
    
    func setImage(with metaData: BaseMetaData) {
        
    }
    
    func setPlaceholderImage(fileType: FileType) {

    }
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        
    }
    
    func setSelectionWithAnimation(isSelectionActive: Bool, isSelected: Bool) {
        
    }
    
    func getAssetId() -> String? {
        return assetId
    }
    
    func setAssetId(_ id: String?) {
        assetId = id
    }
    
    func updating() {
        isAlreadyConfigured = false
    }
    
    func set(name: String?) { }

}
