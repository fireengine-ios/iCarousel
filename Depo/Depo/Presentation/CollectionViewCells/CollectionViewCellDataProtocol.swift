//
//  CollectionViewCellDataProtocol.swift
//  Depo
//
//  Created by Oleg on 05.07.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol CollectionViewCellDataProtocol {
    
    typealias Item = WrapData
    
    func confireWithWrapperd(wrappedObj: BaseDataSourceItem)
    
    func setImage(image: UIImage?)
    
    func setImage(with url: URL)
    
    func setPlaceholderImage(fileType: FileType)
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool)
    
    func setDelegateObject(delegateObject: LBCellsDelegate)
    
    func updating()
    
    func setRequestID(requestID: PHImageRequestID?)
    
    func getRequestID() -> PHImageRequestID?
    
}

