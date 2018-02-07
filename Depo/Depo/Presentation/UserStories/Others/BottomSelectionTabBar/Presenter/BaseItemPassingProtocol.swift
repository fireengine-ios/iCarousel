//
//  BaseItemPassingProtocol.swift
//  Depo
//
//  Created by Aleksandr on 8/3/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol BaseItemInputPassingProtocol: class {
    
    func operationFinished(withType type: ElementTypes, response: Any?)
    func operationFailed(withType type: ElementTypes)
    
    func selectModeSelected()
    func selectAllModeSelected()
    func stopModeSelected()

    func printSelected()
    func changeCover()
    
    var selectedItems: [BaseDataSourceItem] { get }//FOR NOW
}

protocol BaseItemOuputPassingProtocol: class {
    func preparedSelectedItems(items: [Item])
    
    func dismiss(animated: Bool)
    func show(animated: Bool, onView sourceView: UIView?)//
}
