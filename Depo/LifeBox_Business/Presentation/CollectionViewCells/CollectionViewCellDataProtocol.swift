//
//  CollectionViewCellDataProtocol.swift
//  Depo
//
//  Created by Oleg on 05.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol CollectionViewCellDataProtocol {
    
    func configureWithWrapper(wrappedObj: BaseDataSourceItem)
    
    func setImage(image: UIImage?, animated: Bool)
    
    func setImage(with url: URL)
    
    func setImage(with metaData: BaseMetaData)
    
    func setPlaceholderImage(fileType: FileType)
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool)
    
    func setSelectionWithAnimation(isSelectionActive: Bool, isSelected: Bool)
    
    func setDelegateObject(delegateObject: LBCellsDelegate)
    
    func getAssetId() -> String?
    
    func setAssetId(_ id: String?)
    
    func updating()
    
    func set(name: String?)
    
    func cleanCell()

}
