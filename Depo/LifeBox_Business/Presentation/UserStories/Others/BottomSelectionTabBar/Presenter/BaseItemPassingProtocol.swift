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
    func operationCancelled(withType type: ElementTypes)
    func successPopupClosed()
    func successPopupWillAppear()
    
    func showAlert(with message: String)
    
    func selectModeSelected(with item: WrapData?)
    func selectAllModeSelected()
    func deSelectAll()
    func stopModeSelected()
    func renamingSelected(item: Item)
    func printSelected()
    
    func getSelectedItems(selectedItemsCallback: @escaping ValueHandler<[BaseDataSourceItem]>)
    
}

protocol BaseItemOuputPassingProtocol: class {
    func dismiss(animated: Bool)
    func show(animated: Bool, onView sourceView: UIView)
}


extension BaseItemInputPassingProtocol {
    func showAlert(with message: String) {
        DispatchQueue.main.async {
            UIApplication.showErrorAlert(message: message)
        }
    }
    
    func renamingSelected(item: Item) {
        //
    }
    
    func successPopupClosed() {}
    
    func successPopupWillAppear() {}
    
    func operationCancelled(withType type: ElementTypes) {}
}
